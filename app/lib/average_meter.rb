class AverageMeter
  def initialize
    reset
  end

  def reset
    @val = 0
    @avg = 0
    @sum = 0
    @count = 0
  end

  def update(val, n: 1)
    @val = val
    @sum += val * n
    @count += n
    @avg = @sum / @count
  end

end
