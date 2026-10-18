using giuaki.Exams;
using giuaki.Exams.Dto;
using Shouldly;
using System.Collections.Generic;
using Xunit;

namespace giuaki.Tests.Exams;

public class ExamScoring_Tests
{
    [Fact]
    public void Calculate_ShouldCountCorrectIncorrectSkippedAndPercentage()
    {
        var content = new ExamContentDto
        {
            Parts =
            {
                new ExamPartDto
                {
                    Questions =
                    {
                        new ExamQuestionDto { Number = 101, CorrectAnswer = "A" },
                        new ExamQuestionDto { Number = 102, CorrectAnswer = "B" },
                        new ExamQuestionDto { Number = 103, CorrectAnswer = "C" }
                    }
                }
            }
        };

        var score = ExamScoring.Calculate(content, new Dictionary<int, string>
        {
            [101] = "A",
            [102] = "A"
        });

        score.CorrectCount.ShouldBe(1);
        score.IncorrectCount.ShouldBe(1);
        score.SkippedCount.ShouldBe(1);
        score.ScorePercent.ShouldBe(33.33m);
    }
}
