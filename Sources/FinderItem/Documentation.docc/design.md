# Design Principles

Relationships and bindings to files.

## Overview

As the name suggests, ``FinderItem`` represents a *file*, and is strongly bound to the file at the path passed to initializers.

This means:
- A ``FinderItem`` is mutated only when the location of the file changes, for example, by using ``FinderItem/rename(with:keepExtension:)``.
- File operations and file path operations are easily differentiable.
- File operations are `mutating`, and typically accompanied by `throws`.
- However, such mutation is not apparent to users, hence using a shared instance may cause racing.
- File path operations are non-mutating, and always returns a new instance of ``FinderItem``.
