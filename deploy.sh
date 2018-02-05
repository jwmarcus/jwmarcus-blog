#!/bin/bash
rsync -vcr --delete-after -e "ssh -p $DEPLOYPORT" ./_site/ $DEPLOYUSER@$DEPLOYDOMAIN:$PATHTOBLOG
