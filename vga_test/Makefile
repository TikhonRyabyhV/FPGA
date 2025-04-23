VOBJECTS=	vga_testbench.v vga_test.v vga_sync.v

build: $(VOBJECTS)
	@ iverilog $(VOBJECTS)
	@ echo "Exe-file a.out was built."

do_sim: a.out
	@ ./a.out
	@ echo "Simulation was succsessfully completed."

draw_pic: frame.txt
	@ python3 draw_pic.py frame.txt output.png 640 480
	@ echo "Picture output.png was updated."

show_pic:
	@ fim output.png

all: 
	@ iverilog $(VOBJECTS)
	@ echo "Exe-file a.out was built."
	@ ./a.out
	@ echo "Simulation was succsessfully completed."
	@ python3 draw_pic.py frame.txt output.png 640 480
	@ echo "Picture output.png was updated."


