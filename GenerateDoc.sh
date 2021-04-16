#!/bin/bash
echo "Generating Documentation"
rm -r documentation
cd doc_source/document
hugo --minify
mv ./public ../../documentation
