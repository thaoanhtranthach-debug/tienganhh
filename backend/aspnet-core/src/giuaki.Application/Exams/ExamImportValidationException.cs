using System;
using System.Collections.Generic;

namespace giuaki.Exams;

internal sealed class ExamImportValidationException : Exception
{
    public IReadOnlyList<string> Errors { get; }

    public ExamImportValidationException(IReadOnlyList<string> errors)
        : base("The exam document failed validation.")
    {
        Errors = errors;
    }
}
