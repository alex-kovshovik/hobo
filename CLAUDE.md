# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HOBO (Highly Opinionated Budget Organizer) is a Rails 8 budgeting app for couples/families to track spending together. It uses SQLite, Hotwire (Turbo + Stimulus), and deploys via Kamal.

## Common Commands

```bash
# Development
bin/setup              # Initial setup (bundle install, db:prepare)
bin/dev                # Start dev server with Foreman
bin/rails server       # Direct server start

# Testing
bin/rspec              # Run all tests
bin/rspec spec/models  # Run specific directory
bin/rspec spec/models/budget_spec.rb:15  # Run specific test line

# Code Quality
bin/rubocop            # Lint code
bin/brakeman           # Security scan

# Database
bin/rails db:migrate   # Run migrations
bin/rails db:prepare   # Create and load schema

# Deployment (Kamal)
bin/kamal deploy       # Deploy to production
bin/kamal console      # Rails console on remote
bin/kamal shell        # Bash shell on remote
bin/kamal logs         # Tail application logs
bin/kamal dbc          # Database console
```

## Architecture

### Domain Model
- **Family** → has many Users and Budgets
- **User** → belongs to Family, has sessions (built-in Rails 8 auth with bcrypt)
- **Budget** → belongs to Family, has many Expenses (monthly spending categories with icons)
- **Expense** → belongs to Budget, tracks individual spending with creator auditing

### Key Patterns
- **Real-time updates**: Budgets broadcast via Action Cable when expenses change
- **Monthly scoping**: Expenses are filtered by month using `for_month` scope
- **Fragment caching**: Budget cards cache with date-based keys (`cache_key_with_date`)
- **Solid Suite**: Uses Solid Queue, Solid Cache, and Solid Cable (database-backed infrastructure)

### Frontend
- Hotwire (Turbo + Stimulus) for SPA-like behavior
- Bulma CSS framework
- No JavaScript build step (importmap-rails)

### Production
- Deploys to single server via Kamal with local Docker registry
- SQLite database persisted in Docker volume
- SSL via Let's Encrypt (hobo.shovik.com)
