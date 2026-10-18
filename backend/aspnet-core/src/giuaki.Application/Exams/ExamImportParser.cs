using giuaki.Exams.Dto;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using DrawingBlip = DocumentFormat.OpenXml.Drawing.Blip;
using System.Collections.Generic;
using System;
using System.IO.Compression;
using System.IO;
using System.Linq;
using System.Net;
using System.Text.RegularExpressions;

namespace giuaki.Exams;

internal static class ExamImportParser
{
    private const int ExpectedQuestionCount = 100;
    private const int MaximumDocumentCharacters = 2_000_000;
    private const int MaximumEmbeddedImageBytes = 8 * 1024 * 1024;
    private const long MaximumExpandedPackageBytes = 32 * 1024 * 1024;
    private const int MaximumPackageParts = 512;

    private static readonly Regex PartStart = new(
        @"^<PART\s+number=""(?<number>[567])"">$",
        RegexOptions.Compiled | RegexOptions.CultureInvariant);

    private static readonly Regex PassageStart = new(
        @"^<PASSAGE\s+id=""(?<id>[A-Za-z0-9-]{1,64})""\s+type=""(?<type>[A-Za-z0-9-]{1,64})""\s+sourcePages=""(?<pages>\d{1,2}(?:-\d{1,2})?)"">$",
        RegexOptions.Compiled | RegexOptions.CultureInvariant);

    private static readonly Regex QuestionStart = new(
        @"^<QUESTION\s+number=""(?<number>\d{1,3})""(?:\s+passageRef=""(?<passage>[A-Za-z0-9-]{1,64})"")?>$",
        RegexOptions.Compiled | RegexOptions.CultureInvariant);

    public static ExamContentDto Parse(Stream fileStream)
    {
        var content = new ExamContentDto();
        var paragraphs = ReadParagraphs(fileStream, content);
        var errors = new List<string>();
        var allQuestions = new List<ExamQuestionDto>();
        var passageIds = new HashSet<string>(StringComparer.Ordinal);

        var examStarted = false;
        var examEnded = false;
        var titleSeen = false;
        var durationSeen = false;
        var shuffleQuestionsSeen = false;
        var shuffleChoicesSeen = false;
        int? currentPartNumber = null;
        ExamPassageDto currentPassage = null;
        ExamQuestionDto currentQuestion = null;

        foreach (var paragraph in paragraphs)
        {
            var line = paragraph.Text.Trim().Trim('\uFEFF', '\u200B');
            if (line.Length == 0 && paragraph.ImageIds.Count == 0)
            {
                continue;
            }

            var partMatch = PartStart.Match(line);
            var passageMatch = PassageStart.Match(line);
            var questionMatch = QuestionStart.Match(line);
            if (paragraph.ImageIds.Count > 0)
            {
                if (currentQuestion != null)
                {
                    currentQuestion.ImageIds.AddRange(paragraph.ImageIds);
                }
                else if (currentPassage != null && !questionMatch.Success)
                {
                    currentPassage.ImageIds.AddRange(paragraph.ImageIds);
                }
                else if (!passageMatch.Success && !questionMatch.Success)
                {
                    errors.Add("Ảnh trong DOCX phải nằm bên trong PASSAGE hoặc QUESTION.");
                }
            }
            if (line.Length == 0)
            {
                continue;
            }

            if (line == "<EXAM>")
            {
                if (examStarted || currentPartNumber.HasValue)
                {
                    errors.Add("EXAM không được lồng nhau hoặc lặp lại.");
                }
                examStarted = true;
            }
            else if (line == "</EXAM>")
            {
                if (!examStarted || currentPartNumber.HasValue || currentPassage != null || currentQuestion != null)
                {
                    errors.Add("Thẻ đóng EXAM xuất hiện sai vị trí.");
                }
                examEnded = true;
            }
            else if (TryReadValue(line, "TITLE", out var title))
            {
                if (titleSeen || !examStarted || examEnded || currentPartNumber.HasValue)
                {
                    errors.Add("TITLE bị thiếu vị trí hợp lệ hoặc bị lặp.");
                }
                titleSeen = true;
                content.Title = title;
            }
            else if (TryReadValue(line, "DURATION_MINUTES", out var duration))
            {
                if (durationSeen || !examStarted || examEnded || currentPartNumber.HasValue)
                {
                    errors.Add("DURATION_MINUTES bị lặp hoặc sai vị trí.");
                }
                durationSeen = true;
                if (!int.TryParse(duration, out var parsedDuration) || parsedDuration <= 0 || parsedDuration > 600)
                {
                    errors.Add("DURATION_MINUTES phải là số nguyên từ 1 đến 600.");
                }
                else
                {
                    content.DurationMinutes = parsedDuration;
                }
            }
            else if (TryReadValue(line, "SHUFFLE_QUESTIONS", out var shuffleQuestions))
            {
                if (shuffleQuestionsSeen || !examStarted || examEnded || currentPartNumber.HasValue)
                {
                    errors.Add("SHUFFLE_QUESTIONS bị lặp hoặc sai vị trí.");
                }
                shuffleQuestionsSeen = true;
                if (!bool.TryParse(shuffleQuestions, out var parsedShuffleQuestions))
                {
                    errors.Add("SHUFFLE_QUESTIONS chỉ nhận true hoặc false.");
                }
                else
                {
                    content.ShuffleQuestions = parsedShuffleQuestions;
                }
            }
            else if (TryReadValue(line, "SHUFFLE_CHOICES", out var shuffleChoices))
            {
                if (shuffleChoicesSeen || !examStarted || examEnded || currentPartNumber.HasValue)
                {
                    errors.Add("SHUFFLE_CHOICES bị lặp hoặc sai vị trí.");
                }
                shuffleChoicesSeen = true;
                if (!bool.TryParse(shuffleChoices, out var parsedShuffleChoices))
                {
                    errors.Add("SHUFFLE_CHOICES chỉ nhận true hoặc false.");
                }
                else
                {
                    content.ShuffleChoices = parsedShuffleChoices;
                }
            }
            else if (partMatch.Success)
            {
                if (!examStarted || examEnded || currentPartNumber.HasValue || currentPassage != null || currentQuestion != null)
                {
                    errors.Add("PART bị lồng nhau hoặc xuất hiện ngoài EXAM.");
                    continue;
                }

                currentPartNumber = int.Parse(partMatch.Groups["number"].Value);
                content.Parts.Add(new ExamPartDto { Number = currentPartNumber.Value });
            }
            else if (line == "</PART>")
            {
                if (!currentPartNumber.HasValue || currentPassage != null || currentQuestion != null)
                {
                    errors.Add("Thẻ đóng PART xuất hiện sai vị trí.");
                }
                currentPartNumber = null;
            }
            else if (passageMatch.Success)
            {
                if (!currentPartNumber.HasValue || currentPartNumber.Value == 5 || currentPassage != null || currentQuestion != null)
                {
                    errors.Add("PASSAGE chỉ được dùng bên trong Part 6 hoặc Part 7.");
                    continue;
                }

                var id = passageMatch.Groups["id"].Value;
                if (!passageIds.Add(id))
                {
                    errors.Add($"PASSAGE id '{id}' bị trùng.");
                }

                currentPassage = new ExamPassageDto
                {
                    Id = id,
                    Type = passageMatch.Groups["type"].Value,
                    SourcePages = passageMatch.Groups["pages"].Value
                };
                currentPassage.ImageIds.AddRange(paragraph.ImageIds);
                content.Parts.Last().Passages.Add(currentPassage);
            }
            else if (line == "</PASSAGE>")
            {
                if (currentPassage == null || currentQuestion != null)
                {
                    errors.Add("Thẻ đóng PASSAGE xuất hiện sai vị trí.");
                }
                currentPassage = null;
            }
            else if (TryReadValue(line, "PASSAGE_TEXT", out var passageText))
            {
                if (currentPassage == null || !string.IsNullOrWhiteSpace(currentPassage.Text))
                {
                    errors.Add("PASSAGE_TEXT phải xuất hiện đúng một lần bên trong PASSAGE.");
                }
                else
                {
                    currentPassage.Text = passageText;
                }
            }
            else if (questionMatch.Success)
            {
                if (!currentPartNumber.HasValue || currentQuestion != null)
                {
                    errors.Add("QUESTION bị lồng nhau hoặc xuất hiện ngoài PART.");
                    continue;
                }

                var passageReference = questionMatch.Groups["passage"].Success
                    ? questionMatch.Groups["passage"].Value
                    : null;

                if (currentPartNumber.Value == 5 && (currentPassage != null || passageReference != null))
                {
                    errors.Add("Câu Part 5 không được gắn PASSAGE.");
                }
                if (currentPartNumber.Value != 5 && (currentPassage == null || passageReference != currentPassage.Id))
                {
                    errors.Add("Câu Part 6/7 phải tham chiếu PASSAGE đang chứa câu đó.");
                }

                currentQuestion = new ExamQuestionDto
                {
                    Number = int.Parse(questionMatch.Groups["number"].Value),
                    PartNumber = currentPartNumber.Value,
                    PassageId = passageReference,
                    Choices = new Dictionary<string, string>(StringComparer.Ordinal)
                };
                currentQuestion.ImageIds.AddRange(paragraph.ImageIds);
            }
            else if (line == "</QUESTION>")
            {
                if (currentQuestion == null || !currentPartNumber.HasValue)
                {
                    errors.Add("Thẻ đóng QUESTION xuất hiện sai vị trí.");
                    continue;
                }

                if (currentPartNumber.Value == 5)
                {
                    content.Parts.Last().Questions.Add(currentQuestion);
                }
                else if (currentPassage != null)
                {
                    currentPassage.Questions.Add(currentQuestion);
                }

                allQuestions.Add(currentQuestion);
                currentQuestion = null;
            }
            else if (currentQuestion != null && TryReadValue(line, "PROMPT", out var prompt))
            {
                if (!string.IsNullOrWhiteSpace(currentQuestion.Prompt))
                {
                    errors.Add($"Câu {currentQuestion.Number}: PROMPT bị lặp.");
                }
                currentQuestion.Prompt = prompt;
            }
            else if (currentQuestion != null && TryReadChoice(line, out var choiceId, out var choiceText))
            {
                if (currentQuestion.Choices.ContainsKey(choiceId))
                {
                    errors.Add($"Câu {currentQuestion.Number}: lựa chọn {choiceId} bị lặp.");
                }
                else
                {
                    currentQuestion.Choices.Add(choiceId, choiceText);
                }
            }
            else if (currentQuestion != null && TryReadValue(line, "CORRECT_ANSWER", out var answer))
            {
                if (!string.IsNullOrWhiteSpace(currentQuestion.CorrectAnswer))
                {
                    errors.Add($"Câu {currentQuestion.Number}: CORRECT_ANSWER bị lặp.");
                }
                currentQuestion.CorrectAnswer = answer;
            }
            else if (currentQuestion != null && TryReadValue(line, "SOURCE_PAGE", out var sourcePages))
            {
                if (!string.IsNullOrWhiteSpace(currentQuestion.SourcePages))
                {
                    errors.Add($"Câu {currentQuestion.Number}: SOURCE_PAGE bị lặp.");
                }
                currentQuestion.SourcePages = sourcePages;
            }
            else if (line.StartsWith("<", StringComparison.Ordinal))
            {
                errors.Add($"Tag không hợp lệ hoặc sai thứ tự: {Limit(line, 120)}.");
            }
            else
            {
                errors.Add($"Nội dung không được gắn tag: {Limit(line, 120)}.");
            }
        }

        if (!examStarted || !examEnded)
        {
            errors.Add("Thiếu EXAM mở hoặc đóng.");
        }
        if (!titleSeen || string.IsNullOrWhiteSpace(content.Title) || content.Title.Length > 200)
        {
            errors.Add("TITLE bắt buộc, không được trống và tối đa 200 ký tự.");
        }
        if (!durationSeen)
        {
            errors.Add("Thiếu DURATION_MINUTES.");
        }
        if (!shuffleQuestionsSeen || !shuffleChoicesSeen)
        {
            errors.Add("Phải khai báo cả SHUFFLE_QUESTIONS và SHUFFLE_CHOICES.");
        }
        if (currentPartNumber.HasValue || currentPassage != null || currentQuestion != null)
        {
            errors.Add("Có thẻ PART, PASSAGE hoặc QUESTION chưa được đóng.");
        }
        if (content.Parts.Select(part => part.Number).SequenceEqual(new[] { 5, 6, 7 }) == false)
        {
            errors.Add("Đề phải có đúng ba PART theo thứ tự 5, 6, 7.");
        }
        if (allQuestions.Count != ExpectedQuestionCount)
        {
            errors.Add($"Đề phải có đúng {ExpectedQuestionCount} câu; hiện tìm thấy {allQuestions.Count}.");
        }

        for (var index = 0; index < allQuestions.Count; index++)
        {
            var question = allQuestions[index];
            var expectedNumber = 101 + index;
            if (question.Number != expectedNumber)
            {
                errors.Add($"Sai thứ tự câu tại vị trí {index + 1}: cần {expectedNumber}, nhận được {question.Number}.");
            }
            if (question.PartNumber != PartForQuestion(question.Number))
            {
                errors.Add($"Câu {question.Number}: không thuộc đúng Part theo cấu trúc Reading v09.");
            }
            if (string.IsNullOrWhiteSpace(question.Prompt) || ContainsPlaceholder(question.Prompt))
            {
                errors.Add($"Câu {question.Number}: PROMPT còn trống hoặc còn placeholder.");
            }
            if (question.Choices.Count != 4 ||
                !new[] { "A", "B", "C", "D" }.All(question.Choices.ContainsKey))
            {
                errors.Add($"Câu {question.Number}: phải có đúng một lựa chọn A, B, C và D.");
            }
            foreach (var choice in question.Choices)
            {
                if (string.IsNullOrWhiteSpace(choice.Value) || ContainsPlaceholder(choice.Value))
                {
                    errors.Add($"Câu {question.Number}: lựa chọn {choice.Key} còn trống hoặc còn placeholder.");
                }
            }
            if (!new[] { "A", "B", "C", "D" }.Contains(question.CorrectAnswer, StringComparer.Ordinal))
            {
                errors.Add($"Câu {question.Number}: CORRECT_ANSWER phải là A, B, C hoặc D.");
            }
            if (!IsValidSourcePages(question.SourcePages))
            {
                errors.Add($"Câu {question.Number}: SOURCE_PAGE không hợp lệ.");
            }
        }

        foreach (var part in content.Parts)
        {
            foreach (var passage in part.Passages)
            {
                if (string.IsNullOrWhiteSpace(passage.Text) || ContainsPlaceholder(passage.Text))
                {
                    errors.Add($"PASSAGE '{passage.Id}': PASSAGE_TEXT còn trống hoặc còn placeholder.");
                }
                if (passage.Questions.Count == 0)
                {
                    errors.Add($"PASSAGE '{passage.Id}' không có câu hỏi.");
                }
                if (!IsValidSourcePages(passage.SourcePages))
                {
                    errors.Add($"PASSAGE '{passage.Id}': sourcePages không hợp lệ.");
                }
            }
        }

        if (content.Parts.Count == 3)
        {
            if (content.Parts[0].Questions.Count != 30 ||
                content.Parts[1].Passages.Sum(passage => passage.Questions.Count) != 16 ||
                content.Parts[2].Passages.Sum(passage => passage.Questions.Count) != 54)
            {
                errors.Add("Số câu từng phần phải là Part 5: 30, Part 6: 16, Part 7: 54.");
            }
            if (content.Parts[1].Passages.Count != 4 || content.Parts[2].Passages.Count != 15)
            {
                errors.Add("Reading v09 phải có 4 PASSAGE ở Part 6 và 15 PASSAGE ở Part 7.");
            }
        }

        if (errors.Count > 0)
        {
            throw new ExamImportValidationException(errors.Distinct(StringComparer.Ordinal).ToList());
        }

        return content;
    }

    private static List<ExamDocumentParagraph> ReadParagraphs(Stream fileStream, ExamContentDto content)
    {
        try
        {
            ValidatePackageSize(fileStream);
            using var document = WordprocessingDocument.Open(fileStream, false);
            var mainPart = document.MainDocumentPart;
            var body = mainPart?.Document?.Body;
            if (body == null)
            {
                throw new ExamImportValidationException(new[] { "File DOCX không có nội dung Word hợp lệ." });
            }

            var paragraphs = new List<ExamDocumentParagraph>();
            var characterCount = 0;
            var imageBytes = 0;
            var imageIdByRelationship = new Dictionary<string, string>(StringComparer.Ordinal);
            foreach (var paragraph in body.Descendants<Paragraph>())
            {
                var documentParagraph = new ExamDocumentParagraph
                {
                    Text = paragraph.InnerText
                };
                characterCount += documentParagraph.Text.Length;
                foreach (var imageRelationshipId in paragraph.Descendants<DrawingBlip>()
                             .Select(blip => blip.Embed?.Value)
                             .Where(id => !string.IsNullOrWhiteSpace(id)))
                {
                    if (!imageIdByRelationship.TryGetValue(imageRelationshipId, out var imageId))
                    {
                        if (mainPart.GetPartById(imageRelationshipId) is not ImagePart imagePart)
                        {
                            throw new ExamImportValidationException(new[]
                            {
                                $"Tham chiếu ảnh '{imageRelationshipId}' không hợp lệ."
                            });
                        }

                        if (!IsSupportedImageType(imagePart.ContentType))
                        {
                            throw new ExamImportValidationException(new[]
                            {
                                $"Định dạng ảnh '{imagePart.ContentType}' không được hỗ trợ."
                            });
                        }

                        using var imageStream = imagePart.GetStream(FileMode.Open, FileAccess.Read);
                        var imageData = ReadBoundedImage(imageStream, MaximumEmbeddedImageBytes - imageBytes);
                        imageBytes += imageData.Length;
                        imageId = "image-" + (content.Images.Count + 1);
                        imageIdByRelationship.Add(imageRelationshipId, imageId);
                        content.Images.Add(new ExamImageDto
                        {
                            Id = imageId,
                            ContentType = imagePart.ContentType,
                            DataBase64 = Convert.ToBase64String(imageData)
                        });
                    }

                    documentParagraph.ImageIds.Add(imageId);
                }
                paragraphs.Add(documentParagraph);
            }

            if (characterCount > MaximumDocumentCharacters)
            {
                throw new ExamImportValidationException(new[] { "Nội dung DOCX vượt quá giới hạn cho phép." });
            }

            return paragraphs;
        }
        catch (ExamImportValidationException)
        {
            throw;
        }
        catch (Exception exception) when (
            exception is IOException ||
            exception is InvalidDataException ||
            exception is ArgumentException ||
            exception.GetType().Name.Contains("OpenXml", StringComparison.Ordinal))
        {
            throw new ExamImportValidationException(new[]
            {
                "Không đọc được file DOCX. Hãy kiểm tra file .docx và thử lưu lại bằng Microsoft Word."
            });
        }
    }

    private static void ValidatePackageSize(Stream fileStream)
    {
        if (!fileStream.CanSeek)
        {
            throw new ExamImportValidationException(new[]
            {
                "File DOCX không thể được đọc an toàn."
            });
        }

        fileStream.Position = 0;
        using (var package = new ZipArchive(fileStream, ZipArchiveMode.Read, leaveOpen: true))
        {
            if (package.Entries.Count > MaximumPackageParts)
            {
                throw new ExamImportValidationException(new[]
                {
                    "File DOCX chứa quá nhiều thành phần."
                });
            }

            long expandedBytes = 0;
            foreach (var entry in package.Entries)
            {
                expandedBytes += entry.Length;
                if (expandedBytes > MaximumExpandedPackageBytes)
                {
                    throw new ExamImportValidationException(new[]
                    {
                        "Nội dung sau giải nén của DOCX vượt quá giới hạn 32 MB."
                    });
                }
            }

            if (package.GetEntry("[Content_Types].xml") == null ||
                package.GetEntry("word/document.xml") == null)
            {
                throw new ExamImportValidationException(new[]
                {
                    "File ZIP không có cấu trúc Word DOCX hợp lệ."
                });
            }
        }

        fileStream.Position = 0;
    }

    private static byte[] ReadBoundedImage(Stream imageStream, int remainingBytes)
    {
        using var buffer = new MemoryStream();
        var chunk = new byte[81920];
        int bytesRead;
        while ((bytesRead = imageStream.Read(chunk, 0, chunk.Length)) > 0)
        {
            if (bytesRead > remainingBytes - buffer.Length)
            {
                throw new ExamImportValidationException(new[]
                {
                    "Tổng dung lượng ảnh trong DOCX vượt quá 8 MB."
                });
            }

            buffer.Write(chunk, 0, bytesRead);
        }

        return buffer.ToArray();
    }

    private static bool IsSupportedImageType(string contentType)
    {
        return contentType is "image/png" or "image/jpeg" or "image/gif" or "image/bmp" or "image/tiff";
    }

    private static bool TryReadValue(string line, string tagName, out string value)
    {
        var match = Regex.Match(
            line,
            @"^<" + Regex.Escape(tagName) + @">(?<value>.*?)</" + Regex.Escape(tagName) + @">$",
            RegexOptions.CultureInvariant);
        value = match.Success ? WebUtility.HtmlDecode(match.Groups["value"].Value).Trim() : null;
        return match.Success;
    }

    private static bool TryReadChoice(string line, out string choiceId, out string value)
    {
        var match = Regex.Match(
            line,
            @"^<CHOICE\s+id=""(?<id>[A-D])"">(?<value>.*?)</CHOICE>$",
            RegexOptions.CultureInvariant);
        choiceId = match.Groups["id"].Value;
        value = match.Success ? WebUtility.HtmlDecode(match.Groups["value"].Value).Trim() : null;
        return match.Success;
    }

    private static bool ContainsPlaceholder(string value)
    {
        return value.Contains("[Nhập", StringComparison.OrdinalIgnoreCase) ||
               value.Contains("[Điền", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsValidSourcePages(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        var pages = value.Split('-');
        if (!int.TryParse(pages[0], out var first) || first < 1 || first > 29)
        {
            return false;
        }
        if (pages.Length == 1)
        {
            return true;
        }

        return pages.Length == 2 &&
               int.TryParse(pages[1], out var last) &&
               last >= first &&
               last <= 29;
    }

    private static int PartForQuestion(int number)
    {
        if (number is >= 101 and <= 130)
        {
            return 5;
        }
        if (number is >= 131 and <= 146)
        {
            return 6;
        }
        if (number is >= 147 and <= 200)
        {
            return 7;
        }

        return 0;
    }

    private static string Limit(string value, int maximumLength)
    {
        return value.Length <= maximumLength ? value : value[..maximumLength];
    }

    private sealed class ExamDocumentParagraph
    {
        public string Text { get; set; }

        public List<string> ImageIds { get; } = new();
    }
}
