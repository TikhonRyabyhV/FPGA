VOBJECTS=	testbench.v vga.v vga_sync.v gen_addr.v

build: $(VOBJECTS)
	@ iverilog $(VOBJECTS)
	@ echo "Exe-file a.out was built."

do_sim: a.out
	@ ./a.out
	@ echo "Simulation was succsessfully completed."

draw_pic: frame.txt frame_next.txt
	@ python3 draw_pic.py frame.txt output.png 640 480
	@ echo "Picture output.png was updated."
	@ python3 draw_pic.py frame_next.txt output_next.png 640 480
	@ echo "Picture output_next.png was updated."

show_pic:
	@ fim output.png

all: 
	@ iverilog $(VOBJECTS)
	@ echo "Exe-file a.out was built."
	@ ./a.out
	@ echo "Simulation was succsessfully completed."
	@ python3 draw_pic.py frame.txt output.png 640 480
	@ echo "Picture output.png was updated."
	@ python3 draw_pic.py frame_next.txt output_next.png 640 480
	@ echo "Picture output_next.png was updated."
