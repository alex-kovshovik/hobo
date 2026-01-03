# frozen_string_literal: true

require "rails_helper"

describe BudgetPresenter do
  subject do
    described_class.new(budget, date)
  end

  let(:family) { create(:family) }
  let(:budget) { create(:budget, family: family, amount: 100) }
  let(:date) { Date.current.beginning_of_month }

  describe "#total_spent" do
    context "when there are expenses" do
      before do
        create(:expense, budget: budget, amount: 50, date: date)
      end

      it "returns the total spent" do
        expect(subject.total_spent).to eq(50)
      end
    end

    context "when there are no expenses" do
      it "returns 0" do
        expect(subject.total_spent).to eq(0)
      end
    end
  end

  describe "#percent_spent" do
    context "when there are expenses" do
      before do
        create(:expense, budget: budget, amount: 50, date: date)
      end

      it "calculates the percent spent" do
        expect(subject.percent_spent).to eq(50.0)
      end
    end

    context "when there are no expenses" do
      it "returns 0 percent spent" do
        expect(subject.percent_spent).to eq(0.0)
      end
    end
  end

  describe "#percent_of_month" do
    context "when the month is the current month" do
      it "calculates the percent of the month passed" do
        expect(subject.percent_of_month).to be_within(0.1).of((Date.current.day / Date.current.end_of_month.day.to_f) * 100)
      end
    end

    context "when the month is not the current month" do
      let(:date) { Date.current.prev_month.beginning_of_month }

      it "returns 100" do
        expect(subject.percent_of_month).to eq(100)
      end
    end
  end

  describe "#progress_bar_color" do
    def hsl_hue(color)
      color.match(/hsl\((\d+)/)[1].to_i
    end

    context "when on track or under budget" do
      it "returns green" do
        allow(subject).to receive(:percent_spent).and_return(10)
        allow(subject).to receive(:percent_of_month).and_return(20)

        expect(subject.progress_bar_color).to eq("hsl(141, 71%, 48%)")
      end
    end

    context "when exactly on pace" do
      it "returns green" do
        allow(subject).to receive(:percent_spent).and_return(50)
        allow(subject).to receive(:percent_of_month).and_return(50)

        expect(subject.progress_bar_color).to eq("hsl(141, 71%, 48%)")
      end
    end

    context "early in the month (10% through)" do
      before do
        allow(subject).to receive(:percent_of_month).and_return(10)
      end

      it "is forgiving of small excess - stays greenish" do
        allow(subject).to receive(:percent_spent).and_return(20) # 10% excess

        hue = hsl_hue(subject.progress_bar_color)
        expect(hue).to be > 100 # still mostly green
      end

      it "turns yellow with moderate excess" do
        allow(subject).to receive(:percent_spent).and_return(35) # 25% excess

        hue = hsl_hue(subject.progress_bar_color)
        expect(hue).to be_between(40, 80) # yellow range
      end

      it "turns red with large excess" do
        allow(subject).to receive(:percent_spent).and_return(60) # 50% excess

        hue = hsl_hue(subject.progress_bar_color)
        expect(hue).to be < 20 # red
      end
    end

    context "late in the month (90% through)" do
      before do
        allow(subject).to receive(:percent_of_month).and_return(90)
      end

      it "turns orange even with small excess" do
        allow(subject).to receive(:percent_spent).and_return(97) # 7% excess

        hue = hsl_hue(subject.progress_bar_color)
        expect(hue).to be < 100 # already shifted toward red
      end

      it "turns red with moderate excess" do
        allow(subject).to receive(:percent_spent).and_return(105) # 15% excess

        hue = hsl_hue(subject.progress_bar_color)
        expect(hue).to be < 20 # red
      end
    end

    context "comparing early vs late month tolerance" do
      it "is more forgiving early in the month for the same excess" do
        # Early month (10% through) with 15% excess
        early_presenter = described_class.new(budget, date)
        allow(early_presenter).to receive(:percent_of_month).and_return(10)
        allow(early_presenter).to receive(:percent_spent).and_return(25)
        early_hue = hsl_hue(early_presenter.progress_bar_color)

        # Late month (90% through) with 15% excess
        late_presenter = described_class.new(budget, date)
        allow(late_presenter).to receive(:percent_of_month).and_return(90)
        allow(late_presenter).to receive(:percent_spent).and_return(105)
        late_hue = hsl_hue(late_presenter.progress_bar_color)

        expect(early_hue).to be > late_hue # early month should be greener
      end
    end
  end

  describe "#progress_marker_color" do
    it "returns dark color when bar is green" do
      allow(subject).to receive(:percent_spent).and_return(10)
      allow(subject).to receive(:percent_of_month).and_return(50)

      expect(subject.progress_marker_color).to eq("#363636")
    end

    it "returns dark color when bar is yellow" do
      allow(subject).to receive(:percent_spent).and_return(30)
      allow(subject).to receive(:percent_of_month).and_return(10)

      expect(subject.progress_marker_color).to eq("#363636")
    end

    it "returns white when bar is red" do
      allow(subject).to receive(:percent_spent).and_return(80)
      allow(subject).to receive(:percent_of_month).and_return(10)

      expect(subject.progress_marker_color).to eq("#ffffff")
    end
  end
end
