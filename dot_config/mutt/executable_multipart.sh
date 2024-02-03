
#!/bin/bash

# Save the filename
filename="$1"

# Function to display text part
display_text() {
    echo "Text Part:"
    cat "$filename"
}

# Function to display HTML part
display_html() {
    echo "HTML Part:"
    lynx -dump -force_html "$filename"
}

# Function to display images
display_images() {
    echo "Images:"
    # Display images using sxiv or your preferred image viewer
    sxiv "$filename"
}

# Check the content type and call the appropriate function
content_type=$(file --mime-type -b "$filename")

case "$content_type" in
    text/*)
        display_text
        ;;
    image/*)
        display_images
        ;;
    application/xhtml+xml|text/html)
        display_html
        ;;
    *)
        echo "Unknown content type: $content_type"
        ;;
esac



##!/bin/bash

## Save the filename
#filename="$1"

## Display text part
#echo "Text Part:"
#cat "$filename"

## Display HTML part
#echo "HTML Part:"
#lynx -dump -force_html "$filename"

## Display images
#echo "Images:"
#sxiv "$filename"
