package cz.muni.fi.pa164.anomalies.preprocessing;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
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

	public static void main(String[] args) {
		logger.info("Started at " + LocalDateTime.now().toString());
		Properties props = new Properties();
		props.setProperty("annotators", "tokenize, ssplit, pos, lemma");
		StanfordCoreNLP pipeline = new StanfordCoreNLP(props);

		LinkedList<Review> reviews = readReviews();
		for (Review review : reviews) {
			Annotation annotation = annotateDocument(props, pipeline,
					review.getRawText());
			LinkedList<String> lemmata = fetchLemmata(annotation);
			review.setLemmata(String.join(" ", lemmata));
		}

		// TODO: annotating all at once like pipeline.annotate(annotations);
		// causes java.lang.OutOfMemoryError: GC
		// overhead limit exceeded
		// even with 4GB RAM for JVM heap limit

		persistAnnotatedReviews(reviews);
		logger.info("Finished at " + LocalDateTime.now().toString());
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
						+ review.getLemmata() + System.lineSeparator();
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

}
