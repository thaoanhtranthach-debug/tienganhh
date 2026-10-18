$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression

$output = 'C:\Users\AdminMoi\Documents\GIUAKI\Huong_dan_Giua_ky_Reading_v09.docx'
$paragraphs = New-Object 'System.Collections.Generic.List[object]'

function Add-Paragraph([string]$style, [string]$text) {
    $script:paragraphs.Add([pscustomobject]@{ Style = $style; Text = $text })
}

function Add-Question([int]$number, [string]$passageId, [int]$sourcePage) {
    $reference = ''
    if ($passageId) {
        $reference = ' passageRef="' + $passageId + '"'
    }

    Add-Paragraph 'Code' ('    <QUESTION number="' + $number + '"' + $reference + '>')
    Add-Paragraph 'Code' ('      <PROMPT>[Nhập nội dung câu ' + $number + ' từ PDF được cấp quyền.]</PROMPT>')
    foreach ($choice in @('A', 'B', 'C', 'D')) {
        Add-Paragraph 'Code' ('      <CHOICE id="' + $choice + '">[Nhập lựa chọn ' + $choice + ']</CHOICE>')
    }
    Add-Paragraph 'Code' '      <CORRECT_ANSWER>[A|B|C|D — điền sau khi xác minh đáp án]</CORRECT_ANSWER>'
    Add-Paragraph 'Code' ('      <SOURCE_PAGE>' + $sourcePage + '</SOURCE_PAGE>')
    Add-Paragraph 'Code' '    </QUESTION>'
}

function Add-PassageGroup(
    [string]$part,
    [string]$id,
    [string]$type,
    [int]$firstQuestion,
    [int]$lastQuestion,
    [string]$sourcePages
) {
    Add-Paragraph 'Code' ('  <PASSAGE id="' + $id + '" type="' + $type + '" sourcePages="' + $sourcePages + '">')
    Add-Paragraph 'Code' '    <PASSAGE_TEXT>[Nhập nội dung bài đọc/tài liệu từ PDF được cấp quyền; không đổi thứ tự các thành phần.]</PASSAGE_TEXT>'
    for ($number = $firstQuestion; $number -le $lastQuestion; $number++) {
        Add-Question $number $id ([int]($sourcePages -split '-')[0])
    }
    Add-Paragraph 'Code' '  </PASSAGE>'
}

Add-Paragraph 'Title' 'KHUNG TAG ĐỀ THI TOEIC READING'
Add-Paragraph 'Subtitle' 'Reading v09 — 100 câu, Parts 5–7'
Add-Paragraph 'Subtitle' 'Mẫu nhập DOCX cho backend ASP.NET Core / C#'
Add-Paragraph 'Note' 'Đây là khung cấu trúc được lập theo số câu, phần thi, nhóm bài đọc và số trang của PDF Reading v09. Không chứa bản chép câu hỏi, bài đọc, các lựa chọn thật hoặc đáp án TOEIC. Hãy nhập nội dung từ bản PDF được phép sử dụng và lấy khóa đáp án từ giảng viên/nguồn được phép.'

Add-Paragraph 'Heading1' '1. Đối chiếu cấu trúc trong PDF'
Add-Paragraph 'Normal' 'Part 5: câu 101–130 (30 câu độc lập), PDF trang 2–4.'
Add-Paragraph 'Normal' 'Part 6: câu 131–146 (16 câu), bốn nhóm bài đọc: 131–134 (trang 5), 135–138 (trang 6), 139–142 (trang 7), 143–146 (trang 8).'
Add-Paragraph 'Normal' 'Part 7: câu 147–200 (54 câu), 15 nhóm tài liệu; một số nhóm tiếp tục sang trang kế tiếp. Danh sách page ranges và loại tài liệu được ghi trong từng thẻ PASSAGE.'
Add-Paragraph 'Note' 'DURATION_MINUTES = 75 theo hướng dẫn Reading trong PDF. Mỗi câu có bốn lựa chọn A–D; đáp án đúng để trống chờ xác minh.'

Add-Paragraph 'Heading1' '2. Quy ước tag và cách đọc'
Add-Paragraph 'Normal' 'Mỗi dòng mã bên dưới là một đoạn văn Word riêng. Backend đọc văn bản các đoạn DOCX theo thứ tự và phân tích các dòng tag. Tag dưới đây là quy ước dữ liệu của ứng dụng, không phải thẻ HTML tự sinh trong Word.'
Add-Paragraph 'Heading2' 'EXAM'
Add-Paragraph 'Normal' 'Thẻ gốc, đúng một thẻ mỗi file. Mang title, thời lượng, cấu hình trộn và các PART.'
Add-Paragraph 'Heading2' 'TITLE, DURATION_MINUTES'
Add-Paragraph 'Normal' 'Tên đề và thời gian làm bài tính bằng phút. DURATION_MINUTES phải là số nguyên dương.'
Add-Paragraph 'Heading2' 'SHUFFLE_QUESTIONS, SHUFFLE_CHOICES'
Add-Paragraph 'Normal' 'true/false, bật tắt trộn câu và lựa chọn. Khung đặt false để giữ nguyên thứ tự nguồn; Part 6/7 chỉ được trộn câu trong cùng passage.'
Add-Paragraph 'Heading2' 'PART'
Add-Paragraph 'Normal' 'number nhận 5, 6 hoặc 7. Mỗi PART có các QUESTION độc lập hoặc các PASSAGE chứa câu hỏi phụ thuộc bài đọc.'
Add-Paragraph 'Heading2' 'PASSAGE'
Add-Paragraph 'Normal' 'Nhóm câu hỏi gắn với cùng bài đọc/tài liệu. id là định danh ổn định; type mô tả dạng tài liệu; sourcePages ghi trang PDF nguồn; PASSAGE_TEXT dành cho nội dung bài đọc được phép nhập.'
Add-Paragraph 'Heading2' 'QUESTION, PROMPT'
Add-Paragraph 'Normal' 'QUESTION number là số câu gốc. Câu Part 6/7 có passageRef trỏ về PASSAGE gần nhất; PROMPT dành cho nội dung câu hỏi/đoạn khuyết.'
Add-Paragraph 'Heading2' 'CHOICE'
Add-Paragraph 'Normal' 'Mỗi QUESTION cần đúng bốn thẻ CHOICE với id A, B, C, D. Khi xáo trộn, giữ id gốc và chỉ đổi thứ tự hiển thị.'
Add-Paragraph 'Heading2' 'CORRECT_ANSWER'
Add-Paragraph 'Normal' 'Điền đúng một chữ cái A/B/C/D sau khi xác minh khóa đáp án. Backend cần từ chối import/publish khi thiếu, sai định dạng hoặc không khớp một CHOICE.'
Add-Paragraph 'Heading2' 'SOURCE_PAGE'
Add-Paragraph 'Normal' 'Số trang PDF để tra lại nội dung và soát lỗi. Tag tham khảo này có thể lưu thành sourcePage trong CSDL.'
Add-Paragraph 'Heading2' 'Đáp án người học'
Add-Paragraph 'Normal' 'Lựa chọn của thí sinh không ghi đè CORRECT_ANSWER và không nằm trong file đề gốc. Lưu riêng trong AttemptAnswer của lần làm bài.'

Add-Paragraph 'Heading1' '3. Tệp mẫu đã gắn tag — điền nội dung vào chỗ đánh dấu'
Add-Paragraph 'Code' '<EXAM>'
Add-Paragraph 'Code' '  <TITLE>TOEIC Reading Test 09</TITLE>'
Add-Paragraph 'Code' '  <DURATION_MINUTES>75</DURATION_MINUTES>'
Add-Paragraph 'Code' '  <SHUFFLE_QUESTIONS>false</SHUFFLE_QUESTIONS>'
Add-Paragraph 'Code' '  <SHUFFLE_CHOICES>false</SHUFFLE_CHOICES>'

Add-Paragraph 'Code' '  <PART number="5">'
for ($number = 101; $number -le 130; $number++) {
    $sourcePage = 2
    if ($number -ge 109 -and $number -le 120) { $sourcePage = 3 }
    if ($number -ge 121) { $sourcePage = 4 }
    Add-Question $number '' $sourcePage
}
Add-Paragraph 'Code' '  </PART>'

Add-Paragraph 'Code' '  <PART number="6">'
Add-PassageGroup '6' 'P6-131-134' 'email' 131 134 '5'
Add-PassageGroup '6' 'P6-135-138' 'email' 135 138 '6'
Add-PassageGroup '6' 'P6-139-142' 'article' 139 142 '7'
Add-PassageGroup '6' 'P6-143-146' 'article' 143 146 '8'
Add-Paragraph 'Code' '  </PART>'

Add-Paragraph 'Code' '  <PART number="7">'
$part7Groups = @(
    @{ Id = 'P7-147-148'; Type = 'invoice'; First = 147; Last = 148; Pages = '9' },
    @{ Id = 'P7-149-151'; Type = 'advertisement'; First = 149; Last = 151; Pages = '10' },
    @{ Id = 'P7-152-153'; Type = 'text-message-chain'; First = 152; Last = 153; Pages = '11' },
    @{ Id = 'P7-154-155'; Type = 'email'; First = 154; Last = 155; Pages = '12' },
    @{ Id = 'P7-156-157'; Type = 'memo'; First = 156; Last = 157; Pages = '13' },
    @{ Id = 'P7-158-160'; Type = 'letter'; First = 158; Last = 160; Pages = '14' },
    @{ Id = 'P7-161-164'; Type = 'advertisement'; First = 161; Last = 164; Pages = '15' },
    @{ Id = 'P7-165-168'; Type = 'online-chat'; First = 165; Last = 168; Pages = '16-17' },
    @{ Id = 'P7-169-171'; Type = 'article'; First = 169; Last = 171; Pages = '18' },
    @{ Id = 'P7-172-175'; Type = 'notice'; First = 172; Last = 175; Pages = '19' },
    @{ Id = 'P7-176-180'; Type = 'receipt-and-email'; First = 176; Last = 180; Pages = '20-21' },
    @{ Id = 'P7-181-185'; Type = 'contact-form-and-email'; First = 181; Last = 185; Pages = '22-23' },
    @{ Id = 'P7-186-190'; Type = 'emails-and-web-page'; First = 186; Last = 190; Pages = '24-25' },
    @{ Id = 'P7-191-195'; Type = 'advertisement-email-and-press-release'; First = 191; Last = 195; Pages = '26-27' },
    @{ Id = 'P7-196-200'; Type = 'brochure-email-and-schedule'; First = 196; Last = 200; Pages = '28-29' }
)
foreach ($group in $part7Groups) {
    Add-PassageGroup '7' $group.Id $group.Type $group.First $group.Last $group.Pages
}
Add-Paragraph 'Code' '  </PART>'
Add-Paragraph 'Code' '</EXAM>'

Add-Paragraph 'Heading1' '4. Quy tắc import cần triển khai ở backend'
Add-Paragraph 'Normal' 'Đọc các đoạn theo thứ tự; kiểm tra đúng một EXAM, đúng ba PART theo thứ tự 5/6/7, đủ 100 câu từ 101 đến 200, không trùng số câu, mỗi câu đúng bốn CHOICE A–D và đúng một CORRECT_ANSWER.'
Add-Paragraph 'Normal' 'Với Part 6/7, kiểm tra passageRef tồn tại, đúng nhóm và không để câu hỏi rời passage khi shuffle. Kiểm tra sourcePages trong phạm vi trang PDF 1–29.'
Add-Paragraph 'Normal' 'Các placeholder [Nhập ...] và [A|B|C|D ...] là nội dung cần điền, không phải dữ liệu đề hợp lệ. Báo danh sách lỗi kèm số câu/tag; chỉ ghi CSDL khi toàn bộ file hợp lệ, dùng một transaction.'
Add-Paragraph 'Normal' 'Thí sinh chọn đáp án được lưu riêng trong AttemptAnswer. Khi hết 75 phút, deadline do server quyết định; server chấm và tính thống kê, không tin đồng hồ hoặc điểm do Flutter gửi lên.'

Add-Paragraph 'Heading1' '5. Các bước bạn làm tiếp theo'
Add-Paragraph 'Normal' '1. Mở khung Word này và PDF Reading v09 được cấp.'
Add-Paragraph 'Normal' '2. Điền PROMPT và A/B/C/D vào từng QUESTION; nhập PASSAGE_TEXT vào đúng nhóm PASSAGE, giữ nguyên passageRef và thứ tự tài liệu.'
Add-Paragraph 'Normal' '3. Lấy đáp án chính thức từ giảng viên/tài liệu được phép rồi điền CORRECT_ANSWER. Không đoán đáp án.'
Add-Paragraph 'Normal' '4. Backend parse DOCX, validate đủ 100 câu và báo lỗi; sau đó mới lưu, preview và publish.'
Add-Paragraph 'Normal' '5. Nối Flutter vào API để danh sách đề, làm bài 75 phút, lưu/chỉnh đáp án, nộp và nhận kết quả.'

Add-Paragraph 'Heading1' '6. Phạm vi và nguồn'
Add-Paragraph 'Normal' 'Đã đối chiếu cấu trúc từ PDF Reading v09: Part 5/6/7, số câu 101–200, ranh giới nhóm bài đọc và số trang PDF. Nội dung câu hỏi, bài đọc, lựa chọn thật và đáp án không được chép vào tệp này; hãy điền từ nguồn được phép.'
Add-Paragraph 'Normal' 'Tên tag là quy ước rõ ràng cho importer của nhóm, không phải định dạng tag chính thức được PDF quy định. Hãy dùng nguyên tên tag này nhất quán ở bộ đọc DOCX và dữ liệu/API.'

function Escape-XmlText([string]$text) {
    [System.Security.SecurityElement]::Escape($text)
}

$body = New-Object System.Text.StringBuilder
foreach ($paragraph in $paragraphs) {
    $safeText = Escape-XmlText $paragraph.Text
    $null = $body.Append('<w:p><w:pPr><w:pStyle w:val="' + $paragraph.Style + '"/></w:pPr><w:r><w:t xml:space="preserve">' + $safeText + '</w:t></w:r></w:p>')
}

$document = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>' + $body.ToString() + '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="850" w:right="850" w:bottom="850" w:left="850" w:header="400" w:footer="400" w:gutter="0"/></w:sectPr></w:body></w:document>'
$styles = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Aptos" w:hAnsi="Aptos" w:eastAsia="Aptos"/><w:lang w:val="vi-VN"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="100" w:line="252" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style><w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:color w:val="174A7E"/><w:sz w:val="36"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:basedOn w:val="Normal"/><w:rPr><w:color w:val="52677F"/><w:sz w:val="23"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="260" w:after="120"/></w:pPr><w:rPr><w:b/><w:color w:val="174A7E"/><w:sz w:val="27"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="160" w:after="70"/></w:pPr><w:rPr><w:b/><w:color w:val="245B84"/><w:sz w:val="22"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Note"><w:name w:val="Note"/><w:basedOn w:val="Normal"/><w:rPr><w:i/><w:color w:val="8A4B08"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Code"><w:name w:val="Code"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="0" w:line="210"/></w:pPr><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="16"/><w:color w:val="333333"/></w:rPr></w:style></w:styles>'
$rootRelationships = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>'
$documentRelationships = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>'
$contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>'

$fileStream = [IO.File]::Open($output, [IO.FileMode]::Create)
$archive = [System.IO.Compression.ZipArchive]::new($fileStream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
foreach ($entryData in @(
    @{ Name = '[Content_Types].xml'; Text = $contentTypes },
    @{ Name = '_rels/.rels'; Text = $rootRelationships },
    @{ Name = 'word/document.xml'; Text = $document },
    @{ Name = 'word/styles.xml'; Text = $styles },
    @{ Name = 'word/_rels/document.xml.rels'; Text = $documentRelationships }
)) {
    $entry = $archive.CreateEntry($entryData.Name)
    $writer = [IO.StreamWriter]::new($entry.Open(), [Text.UTF8Encoding]::new($false))
    $writer.Write($entryData.Text)
    $writer.Dispose()
}
$archive.Dispose()
$fileStream.Dispose()

Add-Type -AssemblyName System.IO.Compression.FileSystem
$verify = [IO.Compression.ZipFile]::OpenRead($output)
$wordDocument = $verify.GetEntry('word/document.xml')
$reader = [IO.StreamReader]::new($wordDocument.Open())
$savedXml = $reader.ReadToEnd()
$reader.Dispose()
$verify.Dispose()
[xml]$null = $savedXml

$savedText = [System.Net.WebUtility]::HtmlDecode([regex]::Replace($savedXml, '<[^>]+>', ' '))
$questionNumbers = [regex]::Matches($savedText, '<QUESTION number="(\d{3})"')
$choiceCount = [regex]::Matches($savedText, '<CHOICE id="[A-D]">').Count
$answerCount = [regex]::Matches($savedText, '<CORRECT_ANSWER>').Count
$passageCount = [regex]::Matches($savedText, '<PASSAGE id="').Count
$numbers = @($questionNumbers | ForEach-Object { [int]$_.Groups[1].Value })
if ($numbers.Count -ne 100 -or $choiceCount -ne 400 -or $answerCount -ne 100 -or $passageCount -ne 19) {
    throw "Validation failed: questions=$($numbers.Count), choices=$choiceCount, answers=$answerCount, passages=$passageCount."
}
for ($index = 0; $index -lt 100; $index++) {
    if ($numbers[$index] -ne (101 + $index)) {
        throw "Question sequence error at slot $index."
    }
}
Write-Output "Created verified DOCX: $output"
Write-Output "Questions: $($numbers.Count) (101–200); choices: $choiceCount; answer slots: $answerCount; passages: $passageCount; size: $((Get-Item -LiteralPath $output).Length) bytes."
