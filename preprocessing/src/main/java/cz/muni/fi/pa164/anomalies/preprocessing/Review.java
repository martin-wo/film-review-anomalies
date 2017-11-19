package cz.muni.fi.pa164.anomalies.preprocessing;

import edu.stanford.nlp.pipeline.Annotation;

public class Review {
	private String id;
	private int rating;
	private String rawText;
	private String lemmata;
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

	public String getLemmata() {
		return lemmata;
	}

	public void setLemmata(String lemmata) {
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
