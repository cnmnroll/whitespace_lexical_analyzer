require 'strscan'
class WhiteSpace
	# whitespace basic setting
	SPACE = " "; TAB = "\t"; LB = "\n"

	# imp setting
	STACK = SPACE; ARITHMETIC = TAB + SPACE; HEAP = TAB + TAB; FLOW = LB; IO = TAB + LB
	R_IMP = /^#{STACK}|#{ARITHMETIC}|#{HEAP}|#{FLOW}|#{IO}/

		# imp s command init
		STACK_PUSH = SPACE; STACK_DUP_N = TAB + SPACE; STACK_DUP = LB + SPACE; STACK_SLIDE = TAB + TAB; STACK_SWAP = LB + TAB; STACK_DISCARD = LB + LB
	R_CMD_STACK = /^#{STACK_PUSH}|#{STACK_DUP}|#{STACK_SLIDE}|#{STACK_SWAP}|#{STACK_DISCARD}/

		# imp ts command init
		ARITH_ADD = SPACE + SPACE; ARITH_SUB = SPACE + TAB; ARITH_MUL = SPACE + LB; ARITH_DIV = TAB + SPACE; ARITH_MOD = TAB + TAB
	R_CMD_ARITHMETIC = /^#{ARITH_ADD}|#{ARITH_SUB}|#{ARITH_MUL}|#{ARITH_DIV}|#{ARITH_MOD}/

		# imp tt command init
		HEAP_STORE = SPACE; HEAP_LOAD = TAB;
	R_CMD_HEAP = /^#{HEAP_STORE}|#{HEAP_LOAD}/

		# imp l command init
		LABEL_SET = SPACE + SPACE; FLOW_GOSUB = SPACE + TAB; FLOW_JUMP = SPACE + LB; FLOW_BEZ = TAB + SPACE; FLOW_BLTZ = TAB + TAB; FLOW_ENDSUB = TAB + LB; FLOW_HALT = LB + LB;
	R_CMD_FLOW = /^#{LABEL_SET}|#{FLOW_GOSUB}|#{FLOW_JUMP}|#{FLOW_BEZ}|#{FLOW_BLTZ}|#{FLOW_ENDSUB}|#{FLOW_HALT}/

		# imp tl command init
		IO_PUT_CHAR = SPACE + SPACE; IO_PUT_NUM = SPACE + TAB; IO_READ_CHAR = TAB + SPACE; IO_READ_NUM = TAB + TAB
	R_CMD_IO_ = /^#{IO_PUT_CHAR}|#{IO_PUT_NUM}|#{IO_READ_CHAR}|#{IO_READ_NUM}/

		#parameter
		ARGUMENT = "(?:#{SPACE}|#{TAB})"
	R_PRM_S = /^#{ARGUMENT}+$/
	R_PRM_L = /^#{ARGUMENT}{7}+/

	def initialize(file_name)
		begin
			open(file_name) do |file| @buffer = file.read end
		rescue
			puts '開けない'
			exit
		end
		@token = []
		wsEval
	end

	def wsEval
		scanner = StringScanner.new @buffer

		while(!scanner.eos?) do
			unless imp = scanner.scan(R_IMP)
				raise Exception, "undefind imp"
			end
			scanner.scan(/^\n/) if imp == LB
			s_imp = changeImp(imp)

			@token.push s_imp
			#puts s_imp
			unless cmd = scanner.scan(eval('R_CMD_' + s_imp.to_s))
				raise Exception, "undefind cmd"
			end
			s_cmd = changeCmd(imp, cmd)
			@token.push s_cmd
			#puts s_cmd
			if cmd == STACK_PUSH
				unless prm = scanner.scan(R_PRM_S)
					raise Exception, "undefind prm"
				end
				s_prm = changeNumerical(prm)
				@token.push s_prm
			else cmd == LABEL_SET || cmd == FLOW_GOSUB || cmd == FLOW_JUMP || cmd == FLOW_BEZ || cmd == FLOW_BLTZ
				unless prm = scanner.scan(R_PRM_L)
					raise Exception, "undefind prm"
				end
				s_prm = changeAscii(prm)
				@token.push s_prm
			end
			#puts s_prm
			scanner.scan(/^\n/)
			puts s_imp.to_s + ' ' + s_cmd.to_s + ' ' + s_prm.to_s
		end
		puts
		p @token
	end

	def changeImp(imp)
		output = ""
		case imp
		when STACK
			output = :STACK
		when ARITHMETIC
			output = :ARITHMETIC
		when HEAP
			output = :HEAP
		when FLOW
			output = :FLOW
		when IO
			output = :IO
		end

		return output
	end

	def changeCmd(imp, cmd)
		case imp
		when STACK
			case cmd
			when STACK_PUSH
				output = :STACK_PUSH
			when STACK_DUP_N
				output = :STACK_DUP_N
			when STACK_DUP
				output = :STACK_DUP
			when STACK_SLIDE
				output = :STACK_SLIDE
			when STACK_SWAP
				output = :STACK_SWAP
			when STACK_DISCARD
				output = :STACK_DISCARD
			end
		when ARITHMETIC
			case cmd
			when ARITH_ADD
				output = :ARITH_ADD
			when ARITH_SUB
				output = :ARITH_SUB
			when ARITH_MUL
				output = :ARITH_MUL
			when ARITH_DIV
				output = :ARITH_DIV
			when ARITH_MOD
				output = :ARITH_MOD
			end
		when HEAP
			case cmd
			when HEAP_STORE
				output = :HEAP_STORE
			when HEAP_LOAD
				output = :HEAP_LOAD
			end
		when FLOW
			case cmd
			when LABEL_SET
				output = :SET_LABEL
			when FLOW_GOSUB
				output = :FLOW_GOSUB
			when FLOW_JUMP
				output = :FLOW_JUMP
			when FLOW_BEZ
				output = :FLOW_BEZ
			when FLOW_BLTZ
				output = :FLOW_BLTZ
			when FLOW_ENDSUB
				output = :FLOW_ENDSUB
			when FLOW_HALT
				output = :FLOW_HALT
			end
		when IO
			case cmd
			when IO_PUT_CHAR
				output = :IO_PUT_CHAR
			when IO_PUT_NUM
				output = :IO_PUT_NUM
			when IO_READ_CHAR
				output = :IO_READ_CHAR
			when IO_READ_NUM
				output = :IO_READ_NUM
			end
		end
	end

	def changeNumerical(prm)
		prm.gsub /(#{SPACE}|#{TAB})/ do
			$1 == SPACE ? 0 : 1
		end.to_i(2)
	end

	def changeAscii(prm)
		output = ""
		prm.scan /.{8}/ do |char|
			output += changeNumerical(char).chr
		end
		output
	end
end
file_name = ARGV[0]
WhiteSpace.new(file_name)
