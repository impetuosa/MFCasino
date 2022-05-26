Extension { #name : #MOModel }

{ #category : #'*Spinoza' }
MOModel >> simpleModelOntology [

	^ SPOntologyExtractor extractFor: self
]
