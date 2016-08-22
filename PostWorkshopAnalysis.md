# Post-workshop Analysis

As part of the debugging process&mdash;and as a precaution against losing our Internet connection (and so not being able to query the tide data)&mdash;the [Printer_Interface](Printer_Interface/) code saved two files each time it was run:

 * **year-month-results.json** is a cache of the tide data for the given month and year
 * **year-month-out.png** is a copy of the generated pattern

That means that we collected a dataset of general demographic data as a side-effect of running the workshop.  It's not complete - if we got more than one person for any month then only one will be counted; and there were a couple of accidental triggerings which will add the odd extra month here and there.

Still, it gives us an idea of the attendance.  Doing some simple processing will give us some stats.

These instructions all assume some sort of Unix-like shell.  Bash, the default on Ubuntu, will work well, but they will likely work on a Mac too.

## Counts Per Year

    ls *out.png | cut -d - -f 1 | sort | uniq -c > years-summary.csv

Explanation:
 * `ls *.png` - list all the image files
 * `cut -d - -f 1` - split the filename at each '-' character, and just output the first of the resulting list of fields, so for files that are named year-month-out.png this will give a list of years
 * `sort` - sort the results into numeric (in this case, also alphabetic if there'd been any) order
 * `uniq -c` - group any duplicate entries together, and prefix each line with how many entries there were in that group
 * `> years-summary.csv` - save the results in a file called years-summary.csv

This doesn't actually result in a CSV file, but converting it to one is pretty trivial with vim.

 1. Open the file with vim

    `vim years-summary.csv`

 1. Strip out the leading whitespace.  `s/^\s+//` replaces any whitespace (the `\s*`) at the start of the line (`^`) with nothing.  `:g/^\s/` runs the substitution globally on all lines that start with a single space or tab.

    `:g/^\s/s/^\s+//`

 1. Separate the count and year with a comma rather than a space.  `s/ /,/` substitutes any space for a comma.  `:g//...` runs the substitution on all lines (ones that match anything)

    `:g//s/ /,/`

 1. If you like, you can switch the count and year columns in vim too.  Or if it's easier, open the CSV file in a spreadsheet and switch them there.

    `:g/\d/s/\(\d\+\),\(\d\+\)/\2,\1/`

 1. Save the file and exit vim.

    `:wq`

## Montage of Patterns

Given we've got an image of each month's pattern, it would be nice to generate an image of all the patterns.  This will require ImageMagick to be installed.

### All The Patterns

Generate a block of all the patterns, arranged in rows and columns as `montage` sees fit.

    montage *out.png -mode Concatenate -background black all-patterns.png

To make each pattern twice as large...

    montage *out.png -resize 200%x200% -mode Concatenate -background black all-patterns.png

### Year Count Pattern Histogram

Generate a histogram of the number of patterns generated each year, by grouping the pattern images.

 1. Loop through all the years, generating a histogram-year.png for each one. `ls *out.png | cut -d - -f 1 | sort | uniq` gets a list of all the years, which the `for year in...` iterates over.  `montage` generates a montage of all of the patterns (`$year*out.png`) for each year, where `$year` is replaced with each year in turn.  `-label '' label:$year` creates a pseudo-image at the start of the montage, containing the text of the year.  `-tile x1` forces the images to be laid out in a single row. 
```
    for year in `ls *out.png | cut -d - -f 1 | sort | uniq`
    do
        montage -label '' label:$year $year*out.png -mode Concatenate -tile x1 histogram-$year.png
    done
```

 1. Create a montage of all the histogram-year.png images generated in the previous step.  `-tile 1x` puts them into a single column.  `-geometry '1x1+5-9<'` gives a 5 pixel border left and right, and removes the 9 pixels of padding the previous montage generates.

    `montage histogram-*.png -mode Concatenate -tile 1x -geometry '1x1+5-9<' years-histogram.png`

 1. Remove the intermediate image files (optional)

    `rm histogram*.png`

### Patterns Over Time

Create a grid of patterns, with each row containing 12 patterns&mdash;one for each month of the year.

 1. Generate an intermediate script which will generate the images for each year.

```
    for year in `ls *out.png | cut -d - -f 1 | sort | uniq`
    do
        echo "montage \\"
        for month in {1..12}
        do
            if [[ -f "$year-$month-out.png" ]]; then
                echo "$year-$month-out.png \\"
            else
                echo "null: \\"
            fi
        done
        echo " -geometry 24x31 -background black -tile x1 -mode Concatenate full-$year.png"
    done > generate_years
```

 1. Run the script that the previous step generated and saved as `generate_years`

    `. generate_years`

 1. Start off the intermediate script to generate the final montage

    `echo "montage \\" > generate_calendar`

 1. Check which is the first and last year of patterns.  For the #IfIWereTheOcean workshop, these were 1938 and 2019.  Replace those with your years in the following script, which will generate most of the command to create the final montage

```
    for year in {1938..2019}
    do
        if [[ -f "full-$year.png" ]]; then
            echo "full-$year.png \\"
        else
            echo "null: \\"
        fi
    done >> generate_calendar
```

 1. Append the rest of the parameters to montage to the generate_calendar script.

    `echo " -geometry 288x31 -background black -tile 1x -mode Concatenate pattern-calendar.png" >> generate_calendar`

 1. Run the script to generate the final montage image

    `. generate_calendar`

 1. Remove our temporary work files

    `rm generate_years`
    `rm generate_calendar`
    `rm full*.png`

