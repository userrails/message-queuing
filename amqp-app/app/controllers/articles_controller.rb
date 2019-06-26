require "rubygems"
require "amqp"
class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.all
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    #!/usr/bin/env ruby
    # encoding: utf-8


    # EventMachine.run do
    #   connection = AMQP.connect(:host => '127.0.0.1')
    #   puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

    #   channel  = AMQP::Channel.new(connection)
    #   queue    = channel.queue("amqpgem.examples.helloworld", :auto_delete => true)
    #   exchange = channel.direct("")

    #   queue.subscribe do |payload|
    #     puts "Received a message: #{payload}. Disconnecting..."
    #     connection.close { EventMachine.stop }
    #   end

    #   exchange.publish "Hello, world!", :routing_key => queue.name
    # end
    EventMachine.run do
  AMQP.connect do |connection|
    channel  = AMQP::Channel.new(connection)
    # topic exchange name can be any string
    exchange = channel.topic("weathr", :auto_delete => true)

    # Subscribers.
    channel.queue("", :exclusive => true) do |queue|
      queue.bind(exchange, :routing_key => "americas.north.#").subscribe do |headers, payload|
        puts "An update for North America: #{payload}, routing key is #{headers.routing_key}"
      end
    end
    channel.queue("americas.south").bind(exchange, :routing_key => "americas.south.#").subscribe do |headers, payload|
      puts "An update for South America: #{payload}, routing key is #{headers.routing_key}"
    end
    channel.queue("us.california").bind(exchange, :routing_key => "americas.north.us.ca.*").subscribe do |headers, payload|
      puts "An update for US/California: #{payload}, routing key is #{headers.routing_key}"
    end
    channel.queue("us.tx.austin").bind(exchange, :routing_key => "#.tx.austin").subscribe do |headers, payload|
      puts "An update for Austin, TX: #{payload}, routing key is #{headers.routing_key}"
    end
    channel.queue("it.rome").bind(exchange, :routing_key => "europe.italy.rome").subscribe do |headers, payload|
      puts "An update for Rome, Italy: #{payload}, routing key is #{headers.routing_key}"
    end
    channel.queue("asia.hk").bind(exchange, :routing_key => "asia.southeast.hk.#").subscribe do |headers, payload|
      puts "An update for Hong Kong: #{payload}, routing key is #{headers.routing_key}"
    end

    EventMachine.add_timer(1) do
      exchange.publish("San Diego update", :routing_key => "americas.north.us.ca.sandiego").
        publish("Berkeley update",         :routing_key => "americas.north.us.ca.berkeley").
        publish("San Francisco update",    :routing_key => "americas.north.us.ca.sanfrancisco").
        publish("New York update",         :routing_key => "americas.north.us.ny.newyork").
        publish("São Paolo update",        :routing_key => "americas.south.brazil.saopaolo").
        publish("Hong Kong update",        :routing_key => "asia.southeast.hk.hongkong").
        publish("Kyoto update",            :routing_key => "asia.southeast.japan.kyoto").
        publish("Shanghai update",         :routing_key => "asia.southeast.prc.shanghai").
        publish("Rome update",             :routing_key => "europe.italy.roma").
        publish("Paris update",            :routing_key => "europe.france.paris")
    end


    show_stopper = Proc.new {
      connection.close { EventMachine.stop }
    }

    EventMachine.add_timer(2, show_stopper)
  end
end


    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:new)
    end
end
