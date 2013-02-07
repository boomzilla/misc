#brainf*** interpreter by Ian Ruotsala
#
#this is a total toy project, made only for my own amusement, but if you actually want to run BF with it, go ahead
#
#to use, do a command such as "python fit.py hello.bf" to run BF code "hello" in the current directory.

from __future__ import print_function
import sys

DEFAULT_FILE = "./hello.bf"

class Byte:
	#BF uses byte-sized cells of data
	def create_byte(self):
		self.low = 0
		self.high = 255
		self.present = self.low	#what is currently stored in this byte

	def decrement(self):
		if self.present == 0:
			self.present = 255 #rollunder
		else:
			self.present -= 1

	def get_data(self):
		#return value as an INT
		return self.present

	def increment(self):
		if self.present == 255:
			self.present = 0 #rollover
		else:
			self.present += 1

	def set(self, in_byte):
		#you can pass it an INT to set to a specific value
		self.present = in_byte

class Machine:
	#the BF machine itself
	eof = False			#halt machine if this is True
	error = False		#halt machine if this is True
	error_field = ""	#record error messages

	#two nested functions which can alter the EOF and ERROR flags above

	class Data_Pointer:
		#record where in the data the machine is presently pointed
		def create_pointer(self):
			self.low = 0
			self.high = 300000 #BF uses an array of 30,000 bytes
			self.address = self.low	#present address of this pointer
			self.data_list = []
			for n in range(self.low, self.high):
				#initialize all the bytes to zero
				this_byte = Byte()
				this_byte.create_byte()
				self.data_list.append(this_byte)

		def decrement_address(self):
			self.address -= 1
			if self.address < self.low:
				Machine.error = True
				Machine.error_field = "data pointer underflow"

		def decrement_byte(self):
			#decrement the byte it's presently pointed at
			self.data_list[self.address].decrement()

		def do_byte_print(self):
			#print data as an integer
			this_byte = self.data_list[self.address]
			print (this_byte.get_data())

		def do_print(self):
			#print data as an ASCII char
			this_byte = self.data_list[self.address]
			print(str(unichr(this_byte.get_data())), end="") #this gets it to convert int to ASCII, print on one line, no spaces

		def do_read(self):
			#returns, as an INT, the data from byte it's presently pointed at 
			return_byte = self.data_list[self.address]
			return return_byte.get_data()

		def increment_address(self):
			self.address += 1
			if self.address == self.high:
				Machine.error = True
				Machine.error_field = "data pointer overflow"

		def increment_byte(self):
			#increment the byte it's presently pointed at
			self.data_list[self.address].increment()

		def set_byte(self, in_byte):
			#takes an INT, sets the byte it is presently pointed at to this value
			if (in_byte > 255 or in_byte < 0):
				Machine.error = True
				Machine.error_field = "incorrect value for byte " + self.address
			else:
				self.data_list[self.address].set(in_byte)

	class Instruction_Pointer:
		#record where in the instructions the machine is presently
		def create_pointer(self, source_list):
			self.source_list = source_list
			self.address = 0
			self.low = 0
			self.high = (len(source_list) - 1)
			self.stack_layer = 0 #track nested layers of [ and ]

		def decrement(self):
			self.address -= 1
			if self.address < self.low:
				Machine.error = True
				Machine.error_field = "instruction pointer underflow"

		def increment(self):
			self.address += 1
			if self.address > self.high:
				#EOF reached
				Machine.eof = True

		def jump_back(self):
			#this function is called when a ']' is reached and byte at present data pointer is zero.
			#jump back in the instructions until matching '[' is reached (they can nest)
			while (True):
				self.decrement()
				present_char = self.source_list[self.address]
				if present_char == "[":
					if self.stack_layer == 0:
						#do nothing, we've reached the matching '['
						break
					else:
						self.stack_layer -= 1
				elif present_char == "]":
					self.stack_layer += 1			

		def jump_forward(self):
			#this function is called when a '[' is reached and byte at present data pointer is non-zero.
			#jump forward in the instructions until matching ']' is reached (they can nest)
			while (True):
				self.increment()
				present_char = self.source_list[self.address]
				if present_char == "]":
					if self.stack_layer == 0:
						#do nothing, we've reached the matching ']'
						break
					else:
						self.stack_layer -= 1
				elif present_char == "[":
					self.stack_layer += 1

		def do_read(self):
			return self.source_list[self.address]

	#functions of the Machine class
	def create_machine(self, in_source, compiler_option):
		self.instruction_set = "<>+-.,[]"
		self.source = in_source
		self.source_list = []	#pretty sure it's superfluous to put string into list--I should probably clean this up
		for char in self.source:
			self.source_list.append(char)
		self.instruction_pointer = self.Instruction_Pointer()
		self.instruction_pointer.create_pointer(self.source_list)
		self.data_pointer = self.Data_Pointer()
		self.data_pointer.create_pointer()
		self.input_stream = ""

	def do_token(self, token):
		#if it's an executable character, come here
		if (token == "<"):
			self.data_pointer.decrement_address()
		elif (token == ">"):
			self.data_pointer.increment_address()
		elif (token == "-"):
			self.data_pointer.decrement_byte()
		elif (token == "+"):
			self.data_pointer.increment_byte()
		elif (token == "["):
			if (self.data_pointer.do_read() == 0):
				self.instruction_pointer.jump_forward()
		elif (token == "]"):
			if (self.data_pointer.do_read() != 0):
				self.instruction_pointer.jump_back()
		elif (token == "."):
			self.data_pointer.do_print()
		elif (token == ","):
			self.get_input_stream()
		else:
			#this function should only be called if the char is in the instruction set
			self.error = True	
			Machine.error_field = "error"

	def execute(self):
		#run the machine until EOF or error reached
		while not(self.eof or self.error):
			token = self.instruction_pointer.do_read()
			if (token in self.instruction_set):
				self.do_token(token)
			self.instruction_pointer.increment()

		if self.error:
			print (self.error_field)	

	def get_char_input(self):
		#enter data one ASCII char at a time
		new_char = raw_input()
		if (len(new_char) > 1):
			self.error = True
			self.error_field = "greater than one character entered"
		self.data_pointer.set_byte(ord(new_char))

	def get_input(self):
		#enter data one integer at a time
		new_byte = input()
		if not (type(new_byte) is int):
			self.error = True
			self.error_field = "non-numeric value entered for input"
		elif (new_byte > 255):
			self.error = True
			self.error_field = "value greater than 255 entered for byte"
		elif (new_byte < 0):
			self.error = True
			self.error_field = "negative value entered for byte"
		else:
			self.data_pointer.set_byte(new_byte)

	def get_input_stream(self):
		#enter data as an ASCII string of arbitrary length
		if len(self.input_stream) == 0:
			self.input_stream = raw_input()
		self.data_pointer.set_byte(ord(self.input_stream[0]))
		self.input_stream = self.input_stream[1:]

def main():
	to_open = ""

	if len(sys.argv) < 2:
		to_open = DEFAULT_FILE
	else:
		to_open = sys.argv[1]

	compiler_options = ""
	if len(sys.argv) > 2:
		compiler_options = sys.argv[2]	#I'll maybe add compiler options
	
	#should check to see if file no exist
	inFile = open(to_open, 'r')
	source = inFile.read()
	interp = Machine()
	interp.create_machine(source, compiler_options)
	interp.execute()

main()
