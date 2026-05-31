#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_bootstrap'

# Google Docs Skill - Guided Auth Setup
# Walks the user step-by-step through creating OAuth credentials
# and running the authorization flow.

require 'fileutils'
require 'json'

CONFIG_DIR  = ENV['GOOGLE_SKILL_CONFIG_DIR'] || File.join(Dir.home, '.google-docs-skill')
FileUtils.mkdir_p(CONFIG_DIR)
CREDS_PATH  = File.join(CONFIG_DIR, 'client_secret.json')
TOKEN_PATH  = File.join(CONFIG_DIR, 'token.json')

PROJECT_CONSOLE = 'https://console.cloud.google.com/'

# ---------------------------------------------------------------------------
def header(text)
  puts
  puts '=' * 70
  puts "  #{text}"
  puts '=' * 70
  puts
end

def step(number, title)
  puts "--- Step #{number}: #{title} ---"
  puts
end

def prompt(message)
  print "#{message} "
  $stdin.gets
end

def wait_for_enter(message = 'Press Enter when done...')
  print "#{message} "
  $stdin.gets
end

def divider
  puts '-' * 70
end

# ---------------------------------------------------------------------------

puts <<~BANNER

  ╔══════════════════════════════════════════════════════════════════════╗
  ║             Google Docs Skill — OAuth Credentials Setup              ║
  ╚══════════════════════════════════════════════════════════════════════╝

  This wizard will walk you through creating OAuth 2.0 credentials
  so the Google Docs skill can access your documents.

  What you'll need:
    • A Google account
    • A web browser
    • About 5 minutes

  At the end, you'll run the auth flow to grant the skill access.
BANNER

# ---------------------------------------------------------------------------
# Pre-flight: ensure gem directory exists
# ---------------------------------------------------------------------------
header('Checking dependencies')
print '  Checking vendored gems ... '
$stdout.flush

skill_dir = File.expand_path('..', __dir__)
vendor_gems = File.join(skill_dir, 'vendor', 'bundle')
if Dir.exist?(vendor_gems)
  puts 'vendored gems found.'
else
  puts 'vendored gems not found.'
  puts
  puts '  Run: bundle install'
  puts '  (You need bundler installed: gem install bundler)'
  exit 1
end

wait_for_enter("\nReady? Press Enter to begin...")

# ---------------------------------------------------------------------------
# Step 1: Create or select a Google Cloud project
# ---------------------------------------------------------------------------
step(1, 'Open Google Cloud Console')
puts <<~TEXT
  Open this URL in your browser:

    #{PROJECT_CONSOLE}

  • Sign in with your Google account if needed
  • Create a NEW project, or select an existing one from the dropdown
    (top of the page, next to "Google Cloud" logo)

  If creating a new project:
    • Click "New Project"
    • Give it a name, e.g. "Google Docs CLI"
    • Click "Create"

TEXT
wait_for_enter

# ---------------------------------------------------------------------------
# Step 2: Enable the APIs
# ---------------------------------------------------------------------------
step(2, 'Enable Required APIs')
puts <<~TEXT
  In the Google Cloud Console, navigate to:

    APIs & Services  →  Library

  (Use the hamburger menu ☰ in the top-left corner)

  Search for and ENABLE each of these APIs:

    1. Google Docs API
    2. Google Drive API
    3. Google Sheets API
    4. Google Calendar API
    5. People API
    6. Gmail API

  For each one: click its entry, then click the blue "ENABLE" button.

TEXT
wait_for_enter('All 6 APIs enabled? Press Enter...')

# ---------------------------------------------------------------------------
# Step 3: Configure OAuth consent screen
# ---------------------------------------------------------------------------
step(3, 'Configure OAuth Consent Screen')
puts <<~TEXT
  Navigate to:

    APIs & Services  →  OAuth consent screen

  Part A — User Type:
    • Choose "External" and click "Create"

  Part B — App Information:
    • App name:  Google Docs CLI
    • User support email:  your email address
    • Developer contact email:  your email address
    • Leave the app logo, homepage, privacy policy, ToS links empty
    • Click "Save and Continue"

  Part C — Scopes:
    • Nothing to configure — click "Save and Continue"

  Part D — Test Users:
    • Nothing to configure — click "Save and Continue"
    • Review and click "Back to Dashboard"

TEXT
wait_for_enter

# ---------------------------------------------------------------------------
# Step 4: Create OAuth client credentials
# ---------------------------------------------------------------------------
step(4, 'Create OAuth Client Credentials')
puts <<~TEXT
  Navigate to:

    APIs & Services  →  Credentials

  • Click "+ CREATE CREDENTIALS" (top of page)
  • Choose "OAuth client ID"

  On the form:
    • Application type:  Desktop application
    • Name:  CLI Desktop Client
    • Click "Create"

  A dialog will appear with your Client ID and Client Secret.

  ⚠  DO NOT close this dialog yet — you need to download the JSON.

TEXT
wait_for_enter

# ---------------------------------------------------------------------------
# Step 5: Save the credentials
# ---------------------------------------------------------------------------
step(5, 'Download and Save Credentials')
puts <<~TEXT
  In the OAuth client dialog that just appeared:
    • Click "Download JSON"
    • Save the file as:

        #{CREDS_PATH}

  You can do this by moving the downloaded file:

    mv ~/Downloads/client_secret_*.json #{CREDS_PATH}

  Or if you already closed the dialog, find your client in the
  Credentials list, click the download icon (⬇), and save the JSON there.

TEXT

loop do
  wait_for_enter("File saved at #{CREDS_PATH}? Press Enter to verify...")

  if File.exist?(CREDS_PATH)
    puts "  ✓ Credentials file found."
    break
  end

  puts "  ✗ File not found at #{CREDS_PATH}"
  puts "  Make sure you downloaded and saved it there."
end

# ---------------------------------------------------------------------------
# Step 6: Run OAuth flow
# ---------------------------------------------------------------------------
step(6, 'Run the OAuth Authorization Flow')
puts <<~TEXT
  Now the credentials file is in place. The next step is to authorize
  the CLI to access your Google account.

  Running the auth command will:
    1. Open a temporary web server on localhost:3000 (for the callback)
    2. Give you a URL to open in your browser
    3. Google will ask you to sign in and grant permissions
    4. The callback is handled automatically — no code to copy-paste

  Ready?
TEXT

answer = prompt("Run auth flow now? [Y/n]")
unless answer.strip.downcase.start_with?('n')
  puts
  divider
  script_dir = File.dirname(__FILE__)
  exec("ruby #{File.join(script_dir, 'docs_manager.rb')} auth")
end

# ---------------------------------------------------------------------------
# Finished
# ---------------------------------------------------------------------------
puts
header('Setup Complete')
puts "Credentials saved to: #{CREDS_PATH}"
if File.exist?(TOKEN_PATH)
  puts "Auth token saved to:   #{TOKEN_PATH}"
  puts
  puts 'You can now use all Google Docs skill commands!'
else
  puts
  puts 'Auth flow was skipped. Run it manually when ready:'
  puts '  ruby scripts/docs_manager.rb auth'
end
puts
