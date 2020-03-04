get '/packets' do
  @wordlists = Wordlists.all
  @debugindex = params[:id]
  haml :packets_index
end

get '/debug' do
  @wordlist = Wordlists.new
  hash = rand(36**8).to_s(36)
  wordlist = Wordlists.new
  wordlist.type = 'dynamic'
  wordlist.scope = 'hashfile'
  wordlist.name = 'DYNAMIC [hashfile] - '
  wordlist.path = 'control/wordlists/wordlist-' + hash + '.txt'
  wordlist.size = 0
  wordlist.checksum = nil
  wordlist.lastupdated = Time.now
  wordlist.save
  redirect to("/home")
end