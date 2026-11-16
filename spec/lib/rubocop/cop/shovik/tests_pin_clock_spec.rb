# frozen_string_literal: true

require_relative "cop_spec_helper"

RSpec.describe RuboCop::Cop::Shovik::TestsPinClock, :config do
  let(:cop_config) { { "PinningHelpers" => ["PinnedClock", "pinned clock"] } }

  it "flags clock reads in an unpinned example" do
    expect_offense(<<~RUBY)
      it "shows this month" do
        expect(page).to have_content(Date.current.strftime("%B"))
                                     ^^^^^^^^^^^^ Pin the clock (`travel_to`/`freeze_time` in the test or its setup) before calling `Date.current`.
      end
    RUBY
  end

  it "flags every clock API" do
    expect_offense(<<~RUBY)
      test "reads the clock" do
        Date.today
        ^^^^^^^^^^ Pin the clock [...]
        ::Date.yesterday
        ^^^^^^^^^^^^^^^^ Pin the clock [...]
        Time.now
        ^^^^^^^^ Pin the clock [...]
        Time.current
        ^^^^^^^^^^^^ Pin the clock [...]
        Time.zone.now
        ^^^^^^^^^^^^^ Pin the clock [...]
        Time.zone.today
        ^^^^^^^^^^^^^^^ Pin the clock [...]
        DateTime.now
        ^^^^^^^^^^^^ Pin the clock [...]
        3.days.ago
        ^^^^^^^^^^ Pin the clock [...]
        1.week.from_now
        ^^^^^^^^^^^^^^^ Pin the clock [...]
      end
    RUBY
  end

  it "flags clock reads in let blocks of an unpinned group" do
    expect_offense(<<~RUBY)
      describe Budget do
        let(:date) { Date.current }
                     ^^^^^^^^^^^^ Pin the clock [...]
      end
    RUBY
  end

  it "ignores durations and dates that do not read the clock" do
    expect_no_offenses(<<~RUBY)
      it "builds a fixed date" do
        Date.new(2026, 11, 15) + 10.days
        3.days.since(Time.zone.local(2026, 1, 1))
        Time.zone.parse("2026-11-15")
      end
    RUBY
  end

  it "accepts a pin inside the example" do
    expect_no_offenses(<<~RUBY)
      it "shows this month" do
        travel_to Time.zone.local(2026, 11, 15)
        expect(Date.current.day).to eq(15)
      end
    RUBY
  end

  it "accepts reads inside a pinning block" do
    expect_no_offenses(<<~RUBY)
      def build
        freeze_time { Time.current }
        Timecop.freeze(Time.now) { Date.today }
      end
    RUBY
  end

  it "accepts a pin in an around or before hook of an enclosing group" do
    expect_no_offenses(<<~RUBY)
      describe Budget do
        around { |example| travel_to(Time.zone.local(2026, 11, 15)) { example.run } }

        let(:date) { Date.current }

        context "nested" do
          it { expect(Date.current).to eq(date) }
        end
      end

      describe Expense do
        before { freeze_time }

        it { expect(Time.current).to be_present }
      end
    RUBY
  end

  it "accepts a pin in a minitest setup" do
    expect_no_offenses(<<~RUBY)
      class BudgetTest < ActiveSupport::TestCase
        setup { travel_to Time.zone.local(2026, 11, 15) }

        test "today" do
          assert_equal 15, Date.current.day
        end
      end

      class ExpenseTest < ActiveSupport::TestCase
        def setup
          freeze_time
        end

        def test_today
          assert Date.current
        end
      end
    RUBY
  end

  it "accepts a configured pinning helper or shared context" do
    expect_no_offenses(<<~RUBY)
      class BudgetTest < ActiveSupport::TestCase
        include PinnedClock

        test("today") { Date.current }
      end

      describe Expense do
        include_context "pinned clock"

        it { Date.current }
      end
    RUBY
  end

  it "does not treat a pin in a sibling example as pinning" do
    expect_offense(<<~RUBY)
      describe Budget do
        it { travel_to Time.zone.local(2026, 11, 15) }

        it { Date.current }
             ^^^^^^^^^^^^ Pin the clock [...]
      end
    RUBY
  end
end
