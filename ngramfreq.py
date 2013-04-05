#go through the corpus of all English words, and count the n-grams frequencies of their consitutent letters
#needs NLTK installed to run
#
#from command line, run like e.g.: $ python ngramgreq.py 3
#to generate 3-grams
#
#this is something I just threw together one evening, might have some errors, bugs, etc
#
#foo

import sys
import nltk.corpus.reader.cmudict

cmu = nltk.corpus.cmudict.words() #there might be a better corpus than this one, but want to get working before trying another

def process_word(word, N, n_gram_count):
	#go through the word, getting n-grams from it
	end_index = N
	while (end_index <= len(word)):
		ngram = word[end_index - N:end_index]
		if ngram in n_gram_count:
			n_gram_count[ngram] += 1
		else:
			n_gram_count[ngram] = 1
		end_index += 1

def main():
	N = int(sys.argv[1])
	n_gram_count = {} #dictionary which holds (n-gram):(count of n-gram)

	#go through all the English words
	for word in cmu:
		word = word.lower() #so we can accomodate proper nouns
		if (len(word) >= N and word.isalpha()):
			#isaplha function so that, e.g., possessive apostraphies are not introduced
			process_word(word, N, n_gram_count)

	#output results (unsorted: I can write in a sorting function if you want)
	out_name = str(N) + "-gram-results-CMU"
	f = open(out_name, 'w')
	for key in n_gram_count:
		f.write(key + " " + str(n_gram_count[key]) + "\n")

main()
