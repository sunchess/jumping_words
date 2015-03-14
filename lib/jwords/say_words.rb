class SayWords
  include OS

  def initialize(options={})
    @db = DbWords.new
    @collection = @db.collection
    @show_message = options[:show_message].nil? ? SHOW_MESSAGE : options[:show_message]
    @space_words = options[:space_words] || SPACE_WORDS
    @space_interation = options[:space_interation] || SPACE_INTERATION
    @mac_word_voice = options[:mac_word_voice] || MAC_WORD_VOICE
    @mac_translate_voice = options[:mac_translate_voice] || MAC_TRANSLATE_VOICE
    @repeat = options[:repeat] || REPEAT
  end

  def run
    if mac?
      do_mac
    elsif linux?
      do_ubuntu
    end
  end

  private
  def do_ubuntu
    loop do
      @collection.each_with_index do |word, idx|
        rep_times = !word[2].nil? ? word[2].to_i : 1
        @repeat.times do

          rep_times += 1

          puts "#{word[0]}: #{word[1]} | #{rep_times}"
          system 'notify-send -i /usr/share/pixmaps/gnome-irc.png "'+ word[0] +'" "'+ word[1] +'"  -t 1' if @show_message
          system 'espeak -v en -s120 "'+ word[0] +'"'
          sleep @space_words

          system 'espeak -v ru -s120 "'+ word[1] +'"'

          #set number of showing
          @db.update(idx, [word[0], word[1], rep_times])

          sleep @space_words
        end
        sleep @space_interation
      end
      sleep 4 # for notification hiding

      #cleaning
      GC.start
    end
  end

  def do_mac
    loop do
      @collection.each_with_index do |word, idx|
        rep_times = !word[2].nil? ? word[2].to_i : 1
        @repeat.times do

          rep_times += 1

          puts "#{word[0]}: #{word[1]} | #{rep_times}"

          system 'terminal-notifier -message "'+ word[0] +': '+ word[1] +'" -title ""' if @show_message
          system 'say -v ' + @mac_word_voice + ' "'+ word[0] +'"'

          sleep @space_words

          system 'say -v '+ @mac_translate_voice +' "'+ word[1] +'"'

          #set number of showing
          @db.update(idx, [word[0], word[1], rep_times])

          sleep @space_words
        end
        sleep @space_interation
      end
      sleep 4 # for notification hiding

      #cleaning
      GC.start
    end

  end

end
