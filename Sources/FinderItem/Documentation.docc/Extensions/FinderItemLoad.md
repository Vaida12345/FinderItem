# Interacting with the contents

``FinderItem`` offers an integrated way of interacting and loading the contents it represents.

## Topics

### The Loading Calls

These three methods provides the way to load the content.

- ``FinderItem/load(_:)-163we``
- ``FinderItem/load(_:)-9a4yw``
- ``FinderItem/load(_:format:)``


### The Contents

- ``FinderItem/LoadableContent/data``
- ``FinderItem/LoadableContent/resourceBytes``
- ``FinderItem/LoadableContent/lines``

### The Media

- ``FinderItem/LoadableContent/image``
- ``FinderItem/LoadableContent/icon(size:)``
- ``FinderItem/AsyncLoadableContent/preview(size:)``

### The Representation

- ``FinderItem/LoadableContent/fileWrapper(options:)``

### Errors

- ``FinderItem/LoadError``


### The Structures

You should not interact with these structures directly, only the static properties and methods listed above.

- ``FinderItem/LoadableContent``
- ``FinderItem/AsyncLoadableContent``
