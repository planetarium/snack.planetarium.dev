Planetarium Engineering Snack
=============================

This repository contains the contents and the website settings of
Planetarium Engineering Snack, our engineering blog.  The whole website
is compiled into static web pages using [Hugo].

[Hugo]: https://gohugo.io/


Local setup
-----------

 1. Install [Hugo] 0.69.0.

    (You can install it by `brew install hugo` on macOS or
    `choco install hugo-extended` on Windows.)

 2. Clone this Git repository.

 3. In the cloned repository directory, type the following command:

    ~~~~ bash
    hugo server -w -F
    ~~~~

    This watches all file changes so that automatically recompiles them and
    let the browser refresh.


Writing posts
-------------

The posts are placed under *content/posts/* directory.  Posts are organized
according to their published dates and each post is named a short slug with
the three-letter language code, e.g.:

> *content/posts/2019/03/start.kor.md*

To add a new post, type the following command:

~~~~ bash
hugo new posts/`date +%Y/%m`/your-post.eng.md
~~~~

A created draft file would contain the sample front matter too.
The `authors` field is a list of author IDs and you could find all
author IDs from *data/authors/* directory (a *.toml* suffix is not
a part of an author ID).  You probably could not find the author data
file for yourself.  You should create a new author data file by yourself.
