class Ask
  def self.list(title, options)
    Ask.new(title, options).list
  end

  def initialize(title, options)
    @title = title
    @options = options
    @selected = 0
    @last_length = 0
  end

  def list
    print_choices

    @waiting_for_input = true
    while(waiting_for_input) do
      handle_key_input
    end

    selected
  end

  private

  attr_reader :title,
              :options,
              :selected,
              :waiting_for_input

def handle_key_input
  c = read_char

  case c
  when "\r"
    handle_choice
  when "\e[A"
    handle_up
  when "\e[B"
    handle_down
  when "\u0003" # ctrl + c
    exit 0
  when "A"
    handle_up
  when "B"
    handle_down
  end
end

def handle_choice
  @waiting_for_input = false
end

def handle_up
  @selected = selected - 1
  @selected = options.count - 1 if selected < 0
  print_choices
end

def handle_down
  @selected = selected + 1
  @selected = 0 if selected > options.count - 1
  print_choices
end

  def read_char
    $stdin.raw!

    input = $stdin.getc.chr
    if input == "\e" then
      input << $stdin.read_nonblock(3) rescue nil
      input << $stdin.read_nonblock(2) rescue nil
    end
    $stdin.cooked!
    input
  end

  def print_choices
    choices = options.map.with_index do |option, index|
      if index == selected
        "‣ #{option}".blue
      else
        "  #{option}"
      end
    end

    print_to_fit("#{title}\n#{choices.join("\n")}")
  end

  def get_line_width
    `tput cols`.chomp.to_i
  end

  def print_to_fit(str)
    print("\b" * @last_length)

    width = get_line_width
    lines = str.split("\n")
    one_big_line = ""
    lines.each do |line|
      line_for_measure = line.gsub("‣", ">").gsub(/\e\[(\d+)(;\d+)*m/, "").gsub("\e[m", "")
      one_big_line = one_big_line + line + (" " * (width - line_for_measure.length))
    end

    @last_length = one_big_line.length

    print "\r" + one_big_line
  end
end
