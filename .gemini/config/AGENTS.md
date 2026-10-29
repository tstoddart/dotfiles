# Agent Guidelines & User Preferences

## Shell Utilities
- **Content Searching**: Use `rg` (ripgrep) instead of `grep` for searching text within files whenever possible.
- **File Finding**: Use `fd` instead of `find` for finding files or directories whenever possible.
- **CLI Output Optimization**: Use `rtk` (e.g., `rtk ls`, `rtk git`, `rtk read`, `rtk diff`, `rtk err`, `rtk test`) to proxy and summarize CLI outputs before they consume LLM context.
- **Web Content & Article Extraction**: Use `trafilatura` (e.g., `trafilatura -u <URL> --markdown` or `trafilatura -i <file>`) to cleanly scrape, fetch, and extract text, markdown, or metadata from web pages and HTML files.

## Python Tools
- **Python Utilities & Tool Execution**: Always use `uv` or `uvx` (e.g. `uvx <tool>` or `uv run`) for any Python tools, scripts, or one-off dependencies you might need. Do not rely on global pip/python packages.
