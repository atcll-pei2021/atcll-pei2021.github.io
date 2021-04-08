# atcll-pei2021.github.io

## Documentation
### The doc_source folder
On the doc_source folder you have the hugo project that generates the documentation, in the [geekdocs.de guide](https://geekdocs.de/usage/menus/) you have the full documentation on how to write the MD pages

### Where to put the MD Files?
The file tree menu builds a menu from the file system structure of the content folder. By default, areas and subareas are sorted alphabetically by the title of the pages. To manipulate the order the `weight` parameter in a page [front matter](https://gohugo.io/content-management/front-matter/) can be used. To structure your content folder you have to use [page bundles](https://gohugo.io/content-management/organization/#page-bundles), single files are **not** supported. Hugo will render build single files in the content folder just fine but it will not be added to the menu.

**Example:**

File system structure:

```plain
content/
├── level-1
│   ├── _index.md
│   ├── level-1-1.md
│   ├── level-1-2.md
│   └── level-1-3
│       ├── _index.md
│       └── level-1-3-1.md
└── level-2
    ├── _index.md
    ├── level-2-1.md
    └── level-2-2.md
```

Use the content folder on the doc_source directory. Folders and MD names will generate the menu tree

### Build
After you push the code the HUGO Page is automaticly build by a CI/CD github process 

## MicroWebpage
___
Template Name: FlexStart
Template URL: https://bootstrapmade.com/flexstart-bootstrap-startup-template/
Author: BootstrapMade.com
License: https://bootstrapmade.com/license/
