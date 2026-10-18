using Abp.UI;
using giuaki.Exams;
using giuaki.Exams.Dto;
using Shouldly;
using System.Collections.Generic;
using System.Linq;
using Xunit;

namespace giuaki.Tests.Exams;

public class ExamQuestionEditor_Tests
{
    [Fact]
    public void Apply_ShouldUpdateQuestionTextChoicesAndCorrectAnswer()
    {
        var content = CreateContent();
        var edits = CreateEdits();
        edits[0].Prompt = " Updated prompt ";
        edits[0].Choices["B"] = "Updated choice";
        edits[0].CorrectAnswer = "B";

        ExamQuestionEditor.Apply(content, edits);

        content.Parts[0].Questions[0].Prompt.ShouldBe("Updated prompt");
        content.Parts[0].Questions[0].Choices["B"].ShouldBe("Updated choice");
        content.Parts[0].Questions[0].CorrectAnswer.ShouldBe("B");
    }

    [Fact]
    public void Apply_ShouldRejectDuplicateQuestionNumbers()
    {
        var edits = CreateEdits();
        edits[1].Number = edits[0].Number;

        var exception = Should.Throw<UserFriendlyException>(
            () => ExamQuestionEditor.Apply(CreateContent(), edits));

        exception.Message.ShouldContain("không được trùng");
    }

    [Fact]
    public void Apply_ShouldRejectMissingChoices()
    {
        var edits = CreateEdits();
        edits[0].Choices.Remove("D");

        var exception = Should.Throw<UserFriendlyException>(
            () => ExamQuestionEditor.Apply(CreateContent(), edits));

        exception.Message.ShouldContain("A, B, C, D");
    }

    private static ExamContentDto CreateContent()
    {
        return new ExamContentDto
        {
            Parts =
            {
                new ExamPartDto
                {
                    Questions = Enumerable.Range(101, 100)
                        .Select(number =>
                            new ExamQuestionDto
                            {
                                Number = number,
                                Prompt = $"Original prompt {number}",
                                Choices = CreateChoices(),
                                CorrectAnswer = "A"
                            })
                        .ToList()
                }
            }
        };
    }

    private static List<ExamQuestionEditDto> CreateEdits()
    {
        return Enumerable.Range(101, 100)
            .Select(number => new ExamQuestionEditDto
            {
                Number = number,
                Prompt = $"Updated prompt {number}",
                Choices = CreateChoices(),
                CorrectAnswer = "A"
            })
            .ToList();
    }

    private static Dictionary<string, string> CreateChoices()
    {
        return new Dictionary<string, string>
        {
            ["A"] = "Choice A",
            ["B"] = "Choice B",
            ["C"] = "Choice C",
            ["D"] = "Choice D"
        };
    }
}
