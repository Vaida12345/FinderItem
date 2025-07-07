# File Path
File path interpolation conversions.

## Summary

- A leading `/` would redirect to the root folder, such as `/var/`.
- A trailing `/` indicates being a folder, such as `folder/`.

The character `:` is not available in file path, as it is considered as `/`, where `/` is the reserved keyword for the indication of folder. Which means that,
- `folder/file.txt` indicates the `file.txt` inside `folder`.
- `folder:file.txt` indicates the `folder/file.txt` file.
