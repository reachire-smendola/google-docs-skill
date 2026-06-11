# Google Docs Skill

An agent skill for managing Google Docs and Google Drive with comprehensive document and file operations.

## Features

### Google Docs Operations
- Read document content and structure
- Create new documents
- Insert and append text
- Find and replace text
- Text formatting (bold, italic, underline)
- Insert page breaks and images
- Delete content ranges

### Google Drive Operations
- Upload and download files
- Search across Drive
- Create and list folders
- Share files and folders
- Move and organize files
- Export files to different formats (PDF, PNG, etc.)

## Installation

Add this skill to your agent configuration:

```bash
# Clone to your skills directory
git clone https://github.com/robtaylor/google-docs-skill.git ~/.agents/skills/google-docs

# Or add as submodule to your agent config
cd ~/.agents
git submodule add https://github.com/robtaylor/google-docs-skill.git skills/google-docs
```

## Setup

OAuth credentials are **required** for all operations. The quickest way:

```bash
ruby scripts/setup_auth.rb
```

This walks you through creating credentials and authorizing.

### Manual setup

1. **Install gems** (first time): `gem install bundler && bundle install`
2. **Create a Google Cloud Project** at [console.cloud.google.com](https://console.cloud.google.com/)
3. **Enable APIs**: Docs, Drive, Sheets, Calendar, People, Gmail
4. **Configure OAuth consent screen** (External type)
5. **Create OAuth client ID** (Desktop application type)
6. **Download the JSON** and save as `~/.google-docs-skill/client_secret.json`
7. **Run the auth flow**: `ruby scripts/docs_manager.rb auth`

See [SKILL.md](SKILL.md) for complete step-by-step instructions.

## Usage

See [SKILL.md](SKILL.md) for complete documentation and examples.

### Quick Examples

```bash
# Read a document
scripts/docs_manager.rb read <document_id>

# Create a document
echo '{"title": "My Doc", "content": "Hello World"}' | scripts/docs_manager.rb create

# Upload a file to Drive
scripts/drive_manager.rb upload --file ./myfile.pdf --name "My PDF"

# Search Drive
scripts/drive_manager.rb search --query "name contains 'Report'"
```

## License

MIT License - see [LICENSE](LICENSE) for details.
