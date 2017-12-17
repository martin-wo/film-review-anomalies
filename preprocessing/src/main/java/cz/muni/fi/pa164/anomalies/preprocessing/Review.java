package cz.muni.fi.pa164.anomalies.preprocessing;

import java.util.List;

import edu.stanford.nlp.pipeline.Annotation;

public class Review {
	private String id;
	private int rating;
	private String rawText;
	private List<String> lemmata;
	private Annotation annotation;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public int getRating() {
		return rating;
	}

	public void setRating(int rating) {
		this.rating = rating;
	}

	public String getRawText() {
		return rawText;
	}

	public void setRawText(String rawText) {
		this.rawText = rawText;
	}

	public List<String> getLemmata() {
		return lemmata;
	}

	public void setLemmata(List<String> lemmata) {
		this.lemmata = lemmata;
	}

	public Review(String id, int rating, String rawText) {
		this.id = id;
		this.rating = rating;
		this.rawText = rawText;
	}

	public Annotation getAnnotation() {
		return annotation;
	}

	public void setAnnotation(Annotation annotation) {
		this.annotation = annotation;
	}
}
