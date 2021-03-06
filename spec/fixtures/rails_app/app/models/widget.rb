Widget = Struct.new(:name, :price, :tags, :metadata, :created_at, :updated_at) do
  INSTANCE = new(
    'A Widget',
    '1590',
    %w(foo bar baz widget),
    { foo: 'bar' },
    Time.now,
    Time.now
  )

  class << self
    def all
      [find]
    end

    def find(*)
      INSTANCE.dup
    end
  end

  attr_reader :id

  def initialize(*args)
    super
    @id = rand(1_000_000)
  end

  def update(attrs)
    self
  end

  def save
    # noop
    true
  end
end
