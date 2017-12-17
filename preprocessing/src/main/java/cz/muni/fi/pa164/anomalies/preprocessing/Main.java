package cz.muni.fi.pa164.anomalies.preprocessing;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import edu.stanford.nlp.ling.CoreAnnotations.LemmaAnnotation;
import edu.stanford.nlp.ling.CoreAnnotations.SentencesAnnotation;
import edu.stanford.nlp.ling.CoreAnnotations.TokensAnnotation;
import edu.stanford.nlp.ling.CoreLabel;
import edu.stanford.nlp.pipeline.*;
import edu.stanford.nlp.util.CoreMap;

/**
 * Run a series of preprocessing steps and store the output to file.
 */
public class Main {

	private static final Logger logger = LoggerFactory.getLogger(Main.class);
	private static final String CSV_INPUT = "../data/data_html_ascii.csv";
	private static final String CSV_OUTPUT = "../data/preprocessed.csv";
	private static final String STOPWORDS = "../data/stopwords.txt";

	public static void main(String[] args) {
		logger.info("Started at " + LocalDateTime.now().toString());
		Properties props = new Properties();
		props.setProperty("annotators", "tokenize, ssplit, pos, lemma");
		StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
		
		//HashSet<String> stopwords = readStopwords();
		
		LinkedList<Review> reviews = readReviews();
		for (Review review : reviews) {
			Annotation annotation = annotateDocument(props, pipeline,
					review.getRawText());
			LinkedList<String> lemmata = fetchLemmata(annotation);
			//lemmata.removeAll(stopwords);
			review.setLemmata(lemmata);
		}

		List<String> stopwords = getStopwords(reviews);
		for (Review review : reviews) {
			List<String> lemmata = review.getLemmata();
			lemmata.removeAll(stopwords);
			review.setLemmata(lemmata);
		}
		
		// TODO: annotating all at once like pipeline.annotate(annotations);
		// causes java.lang.OutOfMemoryError: GC
		// overhead limit exceeded
		// even with 4GB RAM for JVM heap limit

		persistAnnotatedReviews(reviews);
		logger.info("Finished at " + LocalDateTime.now().toString());
	}
	
	private static List<String> getStopwords(List<Review> reviews) {
		Map<String, Integer> stopwords = new HashMap<>();
		for (Review review : reviews) {
			for (String lemma : review.getLemmata()) {
				Integer n = stopwords.get(lemma);
				n = (n == null) ? 1 : ++n;
				stopwords.put(lemma, n);
			}
		}
		
	    List<Map.Entry<String, Integer>> list = new LinkedList<>(stopwords.entrySet());
	    Collections.sort( list, new Comparator<Map.Entry<String, Integer>>() {
	        @Override
	        public int compare(Map.Entry<String, Integer> o1, Map.Entry<String, Integer> o2) {
	            return (o2.getValue()).compareTo(o1.getValue());
	        }
	    });
	    	
	    LinkedList<String> result = new LinkedList<String>();
	    for (Map.Entry<String, Integer> entry : list) {
	    	result.add(entry.getKey());
	    }
	    
	    return result.subList(0, Math.min(result.size(), 100));
	}
	
	private static LinkedList<String> fetchLemmata(Annotation annotation) {
		LinkedList<String> lemmata = new LinkedList<String>();
		List<CoreMap> sentences = annotation.get(SentencesAnnotation.class);
		for (CoreMap sentence : sentences) {
			for (CoreLabel token : sentence.get(TokensAnnotation.class)) {
				String lemma = token.get(LemmaAnnotation.class);
				lemmata.add(lemma);
			}
		}
		return lemmata;
	}

	private static Annotation annotateDocument(Properties props,
			StanfordCoreNLP pipeline, String rawText) {
		Annotation document = new Annotation(rawText);
		pipeline.annotate(document);
		return document;
	}

	private static void persistAnnotatedReviews(LinkedList<Review> reviews) {
		String csvFile = CSV_OUTPUT;
		String line;
		try (BufferedWriter bw = new BufferedWriter(new FileWriter(csvFile))) {
			Iterator<Review> iterator = reviews.iterator();
			while (iterator.hasNext()) {
				Review review = iterator.next();
				line = review.getId() + ";" + review.getRating() + ";"
						+ String.join(" ", review.getLemmata()) + System.lineSeparator();
				bw.write(line);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private static LinkedList<Review> readReviews() {
		String csvFile = CSV_INPUT;
		LinkedList<Review> reviews = new LinkedList<>();
		String line;

		try (BufferedReader br = new BufferedReader(new FileReader(csvFile))) {
			while ((line = br.readLine()) != null) {
				String[] values = line.split(";");
				reviews.add(new Review(values[0], Integer.parseInt(values[1]),
						values[2]));
			}

		} catch (IOException e) {
			e.printStackTrace();
		}
		return reviews;
	}

	private static HashSet<String> readStopwords() {
		HashSet<String> stopwords = new HashSet<>();
		String line;
		try (BufferedReader br = new BufferedReader(new FileReader(STOPWORDS))) {
			while ((line = br.readLine()) != null) {
				stopwords.add(line.trim());
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return stopwords;
	}
}
