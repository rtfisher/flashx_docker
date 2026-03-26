# How to Install the GitHub CLI (`gh`)

The GitHub CLI is required for creating and connecting to GitHub Codespaces from the command line.

## macOS

```bash
brew install gh
```

## Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install gh
```

## Linux (Fedora/RHEL)

```bash
sudo dnf install gh
```

## Windows

Open **PowerShell** (press **Win + R**, type `powershell`, press Enter) and run:

```
winget install --id GitHub.cli
```

## After Installation

Authenticate with your GitHub account:

```bash
gh auth login
```

Add the Codespaces scope:

```bash
gh auth refresh -h github.com -s codespace
```

You are now ready to create and connect to Codespaces.
