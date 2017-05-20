class String
  def matches(forRegex:)
    lines = split("\n")
    lines.map { |l| l.match(forRegex)&.captures }.flatten.compact
  end

  def clearQuotes
    gsub("\"", with: "")
  end

  def s
    self
  end

  def Bold
    "[bold]#{self}[/]"
  end

  def f
    self
  end

  def Green
    "[green]#{self}[/]"
  end

  def Blue
    "[blue]#{self}[/]"
  end

  def Red
    "[red]#{self}[/]"
  end

  def Yellow
    "[yellow]#{self}[/]"
  end
end
