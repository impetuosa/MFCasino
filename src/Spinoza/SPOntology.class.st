Class {
	#name : #SPOntology,
	#superclass : #Object,
	#instVars : [
		'classes',
		'relations',
		'name'
	],
	#classInstVars : [
		'magact'
	],
	#category : #Spinoza
}

{ #category : #'as yet unclassified' }
SPOntology class >> magact: aSPOntology [

	magact := aSPOntology
]

{ #category : #'as yet unclassified' }
SPOntology >> classes [

	^ classes
]

{ #category : #accessing }
SPOntology >> classes: aCollection [ 
	classes := aCollection
]

{ #category : #'as yet unclassified' }
SPOntology >> drawRoassal [

	| ellipses lines int processed line canvas color |
	ellipses := Dictionary new.
	lines := OrderedCollection new.

	self classes do: [ :c | 
		ellipses at: c ifAbsentPut: [ 
			| el |
			el := RSEllipse new
				      model: c;
				      yourself.

			el color: Color transparent.
			el withBorder.
			el border width: 4.
			el borderColor: Color black.
			el width: 10.
			el radius: (c name copyReplaceAll: 'MO' with: '') size * 4.
			int := RSLabeled new.
			int text: [ c name copyReplaceAll: 'MO' with: '' ].
			int location middle.
			el addInteraction: int.
			el ] ].

	processed := Set new.

	self classes do: [ :p | 
		(processed includes: p) ifFalse: [ 
			processed add: p.
			p outgoingRelations
				select: [ :r | r kind name = #'Is A' ]
				thenDo: [ :rel | 
					rel to do: [ :to | 
						line := RSLine new
							        width: 4;
							        withBorderAttachPoint;
							        from: (ellipses at: p);
							        to: (ellipses at: to);
							        dashArray: #( 5 );
							        model: rel kind;
							        markerEnd: (RSShapeFactory arrow
									         size: 20;
									         color: Color black;
									         yourself);
							        yourself.
						"int := RSLabeled new.
int location middle.
line addInteraction: int."
						lines add: line ] ] ] ].
	canvas := RSCanvas new.
	canvas addAll: ellipses values , lines.
	canvas nodes @ RSDraggable.
	RSForceBasedLayout new
		charge: -2000;
		gravity: 0.001;
		on: canvas nodes.
	canvas @ RSCanvasController.


	lines := OrderedCollection new.
	color := RSColorPalette diverging rdylbu3.
	processed := Set new.

	self classes do: [ :p | 
		(processed includes: p) ifFalse: [ 
			processed add: p.
			p outgoingRelations
				reject: [ :r | r kind name = #'Is A' ]
				thenDo: [ :rel | 
					rel commonUsefulTo
						reject: [ :to | 
							(to name beginsWith: #MO) not or: [ 
								#( MOAnchor MOLanguage MOLanguageObject #MOAccess #MOHtml #MOJava #MOSmalltalk #MOTypeScript #MOPharo #MOVisualWorks #MOAngularTypeScript ) includes: to name ] ]
						thenDo: [ :to | 
							line := RSBezier new
								        controlPointsController:
									        RSDirectedBezierCPAPController new;
								        width: 4;
								        color: (color scale: rel kind);
								        withBorderAttachPoint;
								        from: (ellipses at: p);
								        to: (ellipses at: to);
								        model: rel;
								        markerEnd: (RSShapeFactory arrow
										         size: 20;
										         color: (color scale: rel kind);
										         yourself);
								        yourself.
							int := RSLabeled new.
							int location middle.
							int text: [ :a | a name ].
							line addInteraction: int.

							lines add: line ] ] ] ].
	canvas addAll: lines.

	^ canvas open setLabel: name
]

{ #category : #accessing }
SPOntology >> name: aString [ 
	name := aString
]

{ #category : #'as yet unclassified' }
SPOntology >> relations [

	^ relations
]

{ #category : #accessing }
SPOntology >> relations: aCollection [ 
	relations := aCollection
]

{ #category : #saving }
SPOntology >> saveAs: aString [

	| stream |
	aString asFileReference ensureDelete.
	stream := aString asFileReference writeStream.

	STON put: self onStream: stream.
	stream
		flush;
		close
]
