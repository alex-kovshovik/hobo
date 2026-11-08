# Local test verification: alemarchy4 (Linux x86_64)

Verified on 2026-11-08 against commit `38acec9e6a014b9765076c0c619bd6cfa9055a99`
(`main` HEAD, "Fix stale month progress marker by including current date in cache key").
No application or spec code changed. This document is the only file added.

## Host and toolchain

| Item | Required by repo | Used | Source |
|---|---|---|---|
| OS / arch | n/a | Linux 7.2.15-1-omarchy, x86_64 | `uname` |
| Ruby | 3.4.8 (`.ruby-version`, `.tool-versions`, `Gemfile`) | 3.4.8 (+PRISM), x86_64-linux | `mise install ruby@3.4.8` (precompiled) |
| Bundler | 2.4.19 (`Gemfile.lock` BUNDLED WITH) | 2.4.19 | auto-installed by Bundler 2.6.9 switching to the lockfile version |
| Rails | 8.1.1 (lockfile) | 8.1.1 | lockfile, `BUNDLE_FROZEN=true` |
| rspec-core / rspec-rails | 3.13 / 6.1.5 | same | lockfile |
| Capybara / selenium-webdriver | 3.40.0 / 4.29.1 | same | lockfile |
| sqlite3 gem / bundled libsqlite | 2.6.0 x86_64-linux-gnu | 2.6.0 / 3.49.1 | lockfile (native platform gem) |
| Browser | Chrome (Selenium `:chrome`) | Chromium 155.0.8059.84 (`/usr/bin/chromium`) | system package |
| Driver | chromedriver | ChromeDriver 155.0.8059.84 (`/usr/bin/chromedriver`) | system package |

Ruby 4.0.9 is also installed on this host, but it was **not** used. The repo pins 3.4.8, so
3.4.8 was installed instead of substituting a different version. The browser reported by the
WebDriver session was `browserName=chrome browserVersion=155.0.8059.84`, which confirms the system
Chromium/chromedriver pair was used. Selenium Manager did not download anything (offline mode).

`.tool-versions` also lists `solargraph 0.51.2`. mise warns that it is not in its registry. It is
an editor tool, not needed for tests, and was ignored.

## Isolation and safety settings

- Gems are installed under the worktree's `.bundle/gems` (already gitignored), not into the shared Ruby.
- Test DB: `storage/test.sqlite3` (gitignored), created locally. Only FactoryBot synthetic fixtures are used.
- No `config/master.key` / `RAILS_MASTER_KEY` present or needed. Test env generates `tmp/local_secret.txt`.
- Mail: `config.action_mailer.delivery_method = :test` (repo default). No external HTTP integrations exist in `app/`, `config/`, `lib/`.
- Selenium: `SE_OFFLINE=true`, `SE_AVOID_STATS=true` (no driver downloads, no Selenium Manager telemetry).
- Capybara server binds to 127.0.0.1 (Puma, silent).

Environment used for every command below:

```bash
export BUNDLE_PATH=.bundle/gems BUNDLE_FROZEN=true BUNDLE_APP_CONFIG=.bundle
export RAILS_ENV=test
export SE_OFFLINE=true SE_AVOID_STATS=true DO_NOT_TRACK=1
unset DATABASE_URL RAILS_MASTER_KEY
```

## Commands

```bash
mise install ruby@3.4.8
mise exec ruby@3.4.8 -- bundle install --jobs 8   # exit 0, 129 gems
mise exec ruby@3.4.8 -- bin/rails db:prepare      # exit 0, storage/test.sqlite3

# Default suite (the repo's documented command)
mise exec ruby@3.4.8 -- bin/rspec

# Breakdown runs
mise exec ruby@3.4.8 -- bin/rspec spec/presenters spec/requests
mise exec ruby@3.4.8 -- bin/rspec spec/system --format documentation

# Diagnostic only: examples the repo excludes by default (:skip_ci)
mise exec ruby@3.4.8 -- bin/rspec spec/system --tag skip_ci --format documentation

# Static checks (CLAUDE.md lists bin/rubocop and bin/brakeman, which do not exist in bin/)
mise exec ruby@3.4.8 -- bundle exec rubocop
mise exec ruby@3.4.8 -- bundle exec brakeman --no-pager -q --no-exit-on-warn --no-exit-on-error
```

## Results

The repo has no Rails `test/` suite (only `test/mailers/previews/`). All tests are RSpec.
Every example under `spec/system` is `js: true`, so all of them run in headless Chromium.

| Run | Examples | Pass | Fail | Pending/skip | Excluded by filter | Exit |
|---|---|---|---|---|---|---|
| `bin/rspec` (default, full) | 49 | 49 | 0 | 0 | 8 (`:skip_ci`) | 0 |
| `spec/presenters` (unit) | 17 | 17 | 0 | 0 | 0 | 0 |
| `spec/requests` (integration) | 9 | 9 | 0 | 0 | 0 | 0 |
| `spec/system` (headless Chromium) | 23 | 23 | 0 | 0 | 8 | 0 |
| `spec/system --tag skip_ci` (diagnostic) | 8 | 3 | 5 | 0 | n/a | 1 |
| `rubocop` | 43 files | n/a | 12 offenses | n/a | n/a | 1 |
| `brakeman` 7.0.0 | n/a | 0 warnings, 0 errors | n/a | n/a | n/a | 0 |

Full default run: `49 examples, 0 failures`, finished in 8.93 s. `rails_helper.rb` applies
`config.filter_run_excluding :skip_ci`, so the 8 `:skip_ci` examples are neither run nor counted
in the default result.

### Classification of non-passing items

None of these is a host or infrastructure blocker, and none is an application defect. They are
pre-existing spec or lint issues and have **not** been fixed here (out of scope).

1. **4 `:skip_ci` AJAX examples fail because the CSRF hook in the specs never runs.**
   `spec/system/expense_creation_spec.rb:119, :134, :157, :179`.
   `spec/support/csrf_protection.rb` calls `config.before(:each, type: :system, js: true, prepend: true)`.
   RSpec treats `prepend: true` as a metadata filter, not hook ordering, so the hook only matches
   examples tagged `prepend: true` (there are none). In the browser, `allow_forgery_protection` stays
   `false` and no `<meta name="csrf-token">` is rendered. `Expense#save`
   (`app/javascript/models/expense.js`) then throws on `.content` of `null` before `fetch`. Stimulus
   swallows the error, no POST reaches the server, and the modal stays open.
   Evidence: a scratch probe printed `forgery_protection=false csrf_meta=false calls=[]
   modal_active=true expenses=0`, and `log/test.log` showed no `POST /budgets/:id/expenses`.
   The example also failed in isolation (`bin/rspec spec/system/expense_creation_spec.rb:119`),
   which contradicts the spec comment that it passes individually. With an out-of-repo override
   (`config.prepend_before(:each, type: :system, js: true) { ActionController::Base.allow_forgery_protection = true }`
   loaded via `-r`), the `:skip_ci` set went from 5 failures to 1.
   Production keeps forgery protection on, so the app path is not affected.

2. **1 `:skip_ci` example fails because the click offset in the spec is wrong for Capybara 3.40.**
   `spec/system/expense_creation_spec.rb:23` ("closes when clicking the modal background").
   Capybara 3.40 defaults `w3c_click_offset = true`, so `click(x: 10, y: 10)` is measured from the
   element's center, not its top-left. The probe measured `.modal-background` at 1400x857 from (0,0).
   `elementFromPoint` at center+10 is a numpad `BUTTON` inside the modal content, while (10,10) is
   `.modal-background`. The click never reaches the background.

3. **12 rubocop offenses** in existing files (`budgets_controller.rb`, `authentication.rb`,
   `budget.rb`, `budget_presenter.rb`, `spec/support/capybara.rb`, `expense_creation_spec.rb`). All are
   Style/Layout cops, and 11 are autocorrectable. They are not related to this host.

4. **Documentation drift.** `CLAUDE.md` lists `bin/rubocop` and `bin/brakeman`, but neither binstub
   exists. `bundle exec rubocop` / `bundle exec brakeman` were used instead.

## Suggested follow-ups (not applied)

- `spec/support/csrf_protection.rb`: replace `config.before(..., prepend: true)` with
  `config.prepend_before(:each, type: :system, js: true)`, then re-evaluate removing `:skip_ci` from the AJAX examples.
- `spec/system/expense_creation_spec.rb:29`: compute the click offset from the element center
  (for example, from the background's bounding box), or pin `Capybara.w3c_click_offset = false` for that example.
- Add `bin/rubocop` / `bin/brakeman` binstubs, or update `CLAUDE.md` to use `bundle exec`.
