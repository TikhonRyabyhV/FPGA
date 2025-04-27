from PIL import Image
import argparse

# Set up command-line argument parsing
parser = argparse.ArgumentParser(description="Create an image from a file with RGB data and add a green border")
parser.add_argument('input_file', type=str, help="Path to the input data file")
parser.add_argument('output_file', type=str, help="Name of the output image file")
parser.add_argument('width', type=int, help="Width of the image")
parser.add_argument('height', type=int, help="Height of the image")
args = parser.parse_args()

# Create a new image with extra space for a 1-pixel green border
img = Image.new('RGB', (args.width + 2, args.height + 2), color=(0, 255, 0))  # Green border

# Read data from the input file
with open(args.input_file, 'r') as f:
    lines = [line.strip() for line in f.read().splitlines() if line.strip()]

# Check if the number of lines matches the specified height
if len(lines) != args.height:
    raise ValueError(f"Expected {args.height} lines, found {len(lines)}")

# Process each line
for y, line in enumerate(lines):
    # Split the line into elements
    elements = line.split()
    
    # Check if the number of elements matches the specified width
    if len(elements) != args.width:
        raise ValueError(f"Line {y} expected {args.width} elements, found {len(elements)}")
    
    for x, elem in enumerate(elements):
        if elem.lower() == 'x':
            # Interpret 'x' as red color (0xFF0000)
            r, g, b = 255, 0, 0
        else:
            try:
                num = int(elem)
                # Extract RGB components from 24-bit number
                r = (num >> 16) & 0xFF
                g = (num >> 8) & 0xFF
                b = num & 0xFF
            except ValueError:
                raise ValueError(f"Invalid element '{elem}' in line {y}, expected a number or 'x'")
        
        # Set pixel in the image, offset by 1 pixel for the border
        img.putpixel((x + 1, y + 1), (r, g, b))

# Save the image
img.save(args.output_file)
print(f"Image saved as {args.output_file}")
