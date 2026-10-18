# Backend exam functions

The exam features are application-service APIs only; the lecturer and student UI
is intentionally not included yet.

## Prepare and run

From `backend/aspnet-core`, apply the EF Core migration to the configured SQL
Server database:

```powershell
dotnet run --project src\giuaki.Migrator -- -q
```

Start the API:

```powershell
dotnet run --project src\giuaki.Web.Host
```

Sign in through the existing ABP authentication API. Grant lecturer accounts
the `Pages.Exams.Manage` permission to import, edit, preview, publish, and view
exam analytics. Student exam operations require an authenticated account.

## Lecturer operations

The application service is exposed through ABP's conventional
`/api/services/app/Exam/` routes:

| Operation | Method | Description |
| --- | --- | --- |
| `Import` | POST | Read a `.docx`, validate all tags/questions/choices/answer keys and save only a fully valid exam. |
| `Update` | POST | Replace an existing exam's content with a fully validated `.docx`; published exams remain published. |
| `UpdateQuestions` | POST | Edit prompts, A–D choices, and correct answers on a published exam. |
| `Preview` | GET | Return exam content, correct answers for lecturer review, and embedded raster images. |
| `GetManagedExams` | GET | List imported exams, including draft/publication state. |
| `Publish` | POST | Make an imported exam available to authenticated students. |
| `GetAnalytics` | GET | Return attempt counts, average submitted score, and up to ten most-missed questions. |

`Import` accepts `FileName` and `FileContentBase64`. The decoded DOCX size is
limited to 8 MB. A failed validation returns a user-facing error list; no exam
row is inserted. The server validates the Reading v09 structure (100 ordered
questions, Parts 5–7, 19 passage groups, four choices per question, and one
verified answer key per question). Placeholder content is rejected.

`Update` accepts `ExamId`, `FileName`, and `FileContentBase64` with the same
validation and size limit as `Import`. It replaces the exam content in place;
updating a published exam does not unpublish it, and new attempts use the
updated content. Before an update, existing attempts are pinned to the previous
content so ongoing question delivery, answer validation, scoring, results, and
analytics continue to use the version they started with.

`UpdateQuestions` accepts `ExamId` and a `Questions` array containing all 100
question numbers (101–200), each with `Prompt`, `Choices` (`A`–`D`), and
`CorrectAnswer`. It changes only those question fields; passages, exam metadata,
and publication status remain unchanged. It requires `Pages.Exams.Manage`.
In the Flutter teacher management screen, choose **Tải đề thật**, sign in with
a lecturer account granted that permission, then use **Chỉnh sửa câu hỏi** on a
published exam. The local Flutter web origin `http://localhost:52229` is
included in the development CORS allowlist; adjust `App:CorsOrigins` if the
Flutter development server uses another port.

Example `Update` request body:

Example `UpdateQuestions` body (abbreviated; the actual request must include all
100 questions):

```json
{
  "ExamId": 12,
  "FileName": "reading_exam_v2.docx",
  "FileContentBase64": "<base64-encoded DOCX>"
}
```

```json
{
  "ExamId": 12,
  "Questions": [
    {
      "Number": 101,
      "Prompt": "Updated question text",
      "Choices": {
        "A": "Choice A",
        "B": "Choice B",
        "C": "Choice C",
        "D": "Choice D"
      },
      "CorrectAnswer": "C"
    }
  ]
}
```

## Student operations

| Operation | Method | Description |
| --- | --- | --- |
| `GetAvailableExams` | GET | List published exams with title, duration, and question count. |
| `StartAttempt` | POST | Create a personal attempt and return questions without answer keys and a server-generated deadline. |
| `SaveAnswer` | POST | Set a choice, or clear the choice by sending an empty `ChoiceId`; changing answers is allowed until the deadline. |
| `GetAttempt` | GET | Reload the current user's attempt and saved answers. |
| `Submit` | POST | Close the attempt and return correct, incorrect, skipped, and percentage score. |
| `GetResult` | GET | Retrieve the result after submission or expiry. |

The server owns each attempt's start and deadline timestamps, verifies question
and choice IDs, and only returns attempts to their owning user. If an operation
arrives after the deadline, the server finalizes the attempt and rejects further
answer changes. A backend worker checks for expired attempts every 15 seconds
and finalizes them even if the student is offline; the Flutter timer should
still call `Submit` when it reaches zero for immediate feedback. Expired attempts
are processed in batches of up to 100 per worker run.

## Word tag contract

The parser reads one tag per Word paragraph. Use the tags documented in the
generated `Reading_v09_tagged_template.docx`: `EXAM`, `TITLE`,
`DURATION_MINUTES`, `SHUFFLE_QUESTIONS`, `SHUFFLE_CHOICES`, `PART`, `PASSAGE`,
`PASSAGE_TEXT`, `QUESTION`, `PROMPT`, `CHOICE`, `CORRECT_ANSWER`, and
`SOURCE_PAGE`. Questions 131–200 must reference the passage that contains
them. Embedded PNG, JPEG, GIF, BMP, and TIFF images are returned with stable
image IDs for the preview/student clients.

The parser is intentionally specific to the supplied Reading v09 exam shape;
it does not accept arbitrary exam lengths or custom part definitions.

## Verification

Run the focused parser tests:

```powershell
dotnet test test\giuaki.Tests\giuaki.Tests.csproj --filter FullyQualifiedName~ExamImportParser_Tests
```
