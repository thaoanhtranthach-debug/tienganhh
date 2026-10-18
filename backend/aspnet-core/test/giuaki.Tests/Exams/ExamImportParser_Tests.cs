using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using giuaki.Exams;
using Shouldly;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Xunit;

namespace giuaki.Tests.Exams;

public class ExamImportParser_Tests
{
    [Fact]
    public void Parse_ShouldAcceptACompleteTaggedReadingExam()
    {
        using var document = CreateExamDocument();

        var result = ExamImportParser.Parse(document);

        result.Title.ShouldBe("Test Reading");
        result.DurationMinutes.ShouldBe(75);
        result.Parts.Count.ShouldBe(3);
        result.Parts[0].Questions.Count.ShouldBe(30);
        result.Parts[1].Passages.Count.ShouldBe(4);
        result.Parts[2].Passages.Count.ShouldBe(15);
        result.Parts.SelectMany(part => part.Questions)
            .Concat(result.Parts.SelectMany(part => part.Passages.SelectMany(passage => passage.Questions)))
            .Select(question => question.Number)
            .OrderBy(number => number)
            .ShouldBe(Enumerable.Range(101, 100));
    }

    [Fact]
    public void Parse_ShouldRejectMissingCorrectAnswers()
    {
        using var document = CreateExamDocument(missingAnswerFor: 101);

        var exception = Should.Throw<ExamImportValidationException>(() => ExamImportParser.Parse(document));

        exception.Errors.ShouldContain(error => error.Contains("Câu 101"));
    }

    [Fact]
    public void Parse_ShouldRejectQuestionsInTheWrongOrder()
    {
        using var document = CreateExamDocument(swapFirstPart5Questions: true);

        var exception = Should.Throw<ExamImportValidationException>(() => ExamImportParser.Parse(document));

        exception.Errors.ShouldContain(error => error.Contains("Sai thứ tự câu"));
    }

    [Fact]
    public void Parse_ShouldRejectPlaceholderText()
    {
        using var document = CreateExamDocument(placeholderFor: 101);

        var exception = Should.Throw<ExamImportValidationException>(() => ExamImportParser.Parse(document));

        exception.Errors.ShouldContain(error => error.Contains("PROMPT còn trống"));
    }

    [Fact]
    public void Parse_ShouldRejectANonDocxFile()
    {
        using var document = new MemoryStream(new byte[] { 0x50, 0x4B, 0x03, 0x04 });

        var exception = Should.Throw<ExamImportValidationException>(() => ExamImportParser.Parse(document));

        exception.Errors.ShouldContain(error => error.Contains("DOCX"));
    }

    private static MemoryStream CreateExamDocument(
        int? missingAnswerFor = null,
        int? placeholderFor = null,
        bool swapFirstPart5Questions = false)
    {
        var lines = new List<string>
        {
            "<EXAM>",
            "<TITLE>Test Reading</TITLE>",
            "<DURATION_MINUTES>75</DURATION_MINUTES>",
            "<SHUFFLE_QUESTIONS>false</SHUFFLE_QUESTIONS>",
            "<SHUFFLE_CHOICES>false</SHUFFLE_CHOICES>",
            "<PART number=\"5\">"
        };

        var part5Numbers = Enumerable.Range(101, 30).ToArray();
        if (swapFirstPart5Questions)
        {
            (part5Numbers[0], part5Numbers[1]) = (part5Numbers[1], part5Numbers[0]);
        }

        foreach (var questionNumber in part5Numbers)
        {
            AddQuestion(lines, questionNumber, null, missingAnswerFor, placeholderFor);
        }
        lines.Add("</PART>");

        lines.Add("<PART number=\"6\">");
        var part6Groups = new[]
        {
            (First: 131, Last: 134, Page: "5"),
            (First: 135, Last: 138, Page: "6"),
            (First: 139, Last: 142, Page: "7"),
            (First: 143, Last: 146, Page: "8")
        };
        foreach (var group in part6Groups)
        {
            AddPassage(lines, $"P6-{group.First}-{group.Last}", "email", group.Page, group.First, group.Last, missingAnswerFor, placeholderFor);
        }
        lines.Add("</PART>");

        lines.Add("<PART number=\"7\">");
        var part7Groups = new[]
        {
            (First: 147, Last: 148, Type: "invoice", Pages: "9"),
            (First: 149, Last: 151, Type: "advertisement", Pages: "10"),
            (First: 152, Last: 153, Type: "text-message-chain", Pages: "11"),
            (First: 154, Last: 155, Type: "email", Pages: "12"),
            (First: 156, Last: 157, Type: "memo", Pages: "13"),
            (First: 158, Last: 160, Type: "letter", Pages: "14"),
            (First: 161, Last: 164, Type: "advertisement", Pages: "15"),
            (First: 165, Last: 168, Type: "online-chat", Pages: "16-17"),
            (First: 169, Last: 171, Type: "article", Pages: "18"),
            (First: 172, Last: 175, Type: "notice", Pages: "19"),
            (First: 176, Last: 180, Type: "receipt-and-email", Pages: "20-21"),
            (First: 181, Last: 185, Type: "contact-form-and-email", Pages: "22-23"),
            (First: 186, Last: 190, Type: "emails-and-web-page", Pages: "24-25"),
            (First: 191, Last: 195, Type: "advertisement-email-and-press-release", Pages: "26-27"),
            (First: 196, Last: 200, Type: "brochure-email-and-schedule", Pages: "28-29")
        };
        foreach (var group in part7Groups)
        {
            AddPassage(lines, $"P7-{group.First}-{group.Last}", group.Type, group.Pages, group.First, group.Last, missingAnswerFor, placeholderFor);
        }
        lines.Add("</PART>");
        lines.Add("</EXAM>");

        var memory = new MemoryStream();
        using (var document = WordprocessingDocument.Create(
                   memory,
                   WordprocessingDocumentType.Document,
                   autoSave: true))
        {
            var mainPart = document.AddMainDocumentPart();
            var body = new Body();
            foreach (var line in lines)
            {
                body.AppendChild(new Paragraph(new Run(new Text(line))));
            }
            mainPart.Document = new Document(body);
            mainPart.Document.Save();
        }

        memory.Position = 0;
        return memory;
    }

    private static void AddPassage(
        ICollection<string> lines,
        string id,
        string type,
        string pages,
        int firstQuestion,
        int lastQuestion,
        int? missingAnswerFor,
        int? placeholderFor)
    {
        lines.Add($"<PASSAGE id=\"{id}\" type=\"{type}\" sourcePages=\"{pages}\">");
        lines.Add("<PASSAGE_TEXT>A test passage with no copyrighted content.</PASSAGE_TEXT>");
        for (var number = firstQuestion; number <= lastQuestion; number++)
        {
            AddQuestion(lines, number, id, missingAnswerFor, placeholderFor);
        }
        lines.Add("</PASSAGE>");
    }

    private static void AddQuestion(
        ICollection<string> lines,
        int number,
        string passageId,
        int? missingAnswerFor,
        int? placeholderFor)
    {
        var passageReference = passageId == null ? string.Empty : $" passageRef=\"{passageId}\"";
        lines.Add($"<QUESTION number=\"{number}\"{passageReference}>");
        lines.Add(placeholderFor == number
            ? $"<PROMPT>[Nhập nội dung câu {number}]</PROMPT>"
            : $"<PROMPT>Which option completes sample question {number}?</PROMPT>");
        lines.Add("<CHOICE id=\"A\">alpha</CHOICE>");
        lines.Add("<CHOICE id=\"B\">bravo</CHOICE>");
        lines.Add("<CHOICE id=\"C\">charlie</CHOICE>");
        lines.Add("<CHOICE id=\"D\">delta</CHOICE>");
        if (missingAnswerFor != number)
        {
            lines.Add("<CORRECT_ANSWER>A</CORRECT_ANSWER>");
        }
        lines.Add($"<SOURCE_PAGE>{PageForQuestion(number)}</SOURCE_PAGE>");
        lines.Add("</QUESTION>");
    }

    private static int PageForQuestion(int number)
    {
        if (number <= 108) return 2;
        if (number <= 120) return 3;
        if (number <= 130) return 4;
        if (number <= 134) return 5;
        if (number <= 138) return 6;
        if (number <= 142) return 7;
        if (number <= 146) return 8;
        if (number <= 148) return 9;
        if (number <= 151) return 10;
        if (number <= 153) return 11;
        if (number <= 155) return 12;
        if (number <= 157) return 13;
        if (number <= 160) return 14;
        if (number <= 164) return 15;
        if (number <= 168) return 16;
        if (number <= 171) return 18;
        if (number <= 175) return 19;
        if (number <= 180) return 20;
        if (number <= 185) return 22;
        if (number <= 190) return 24;
        if (number <= 195) return 26;
        return 28;
    }
}
