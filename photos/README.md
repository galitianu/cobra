# Photos

Board photos referenced from the journal. Name them `YYYYMMDD_<subject>.jpg`, e.g. `20261029_board_top.jpg`.

Before committing, strip location and camera metadata (the pre-commit hook refuses files that still have it):

    exiftool -all= -tagsfromfile @ -Orientation -overwrite_original photos/*.jpg

Resize large phone photos to about 2500 px on the long side to keep the repo small:

    sips -Z 2500 photos/*.jpg
