Widget = Struct.new(:name, :price, :tags, :metadata, :created_at, :updated_at) do
  class << self
    def all
      [
        new(
          'A Widget',
          '1590',
          %w(foo bar baz widget),
          { foo: 'bar' },
          Time.now,
          Time.now
        )
      ]
    end
  end

  attr_reader :id

  def initialize(*args)
    super
    @id = rand(1_000_000)
  end

  def save
    # noop
  end
end
