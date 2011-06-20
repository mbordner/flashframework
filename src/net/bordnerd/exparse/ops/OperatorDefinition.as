package net.bordnerd.exparse.ops {
	/**
	 * @author michael.bordner
	 */
	public class OperatorDefinition 
	{
		private var numPrecedence:Number = -1;
		private var numTerms:Number = -1;
		private var numAssociativity:Number = -1;
		
		/**
		 * Encapsulates information about an operator such as precedence, number of terms and associativity.
		 * 
		 * @param numPrecedence the operatory precedence, when comparing two operators, the higher predence operator will have the highest p value
		 * @param numTerms number of terms, for example, is it a unary, binary or tertiary operator
		 * @param numAssociativity associativity of the operator, if it is left associative the value will be 0, if it is right associative the value will be 1..  in other words, which side is evaluated first.
		 */
		public function OperatorDefinition( numPrecedence:Number, numTerms:Number, numAssociativity:Number ) {
			this.numPrecedence = numPrecedence;
			this.numTerms = numTerms;
			this.numAssociativity = numAssociativity;
		}
		
		/**
		 * @return the operatory precedence, when comparing two operators, the higher predence operator will have the highest p value
		 */
		public function get p():Number {
			return this.numPrecedence;	
		}
		
		/**
		 * @return number of terms, for example, is it a unary, binary or tertiary operator
		 */
		public function get t():Number {
			return this.numTerms;	
		}
		
		/**
		 * @return associativity of the operator, if it is left associative the value will be 0, if it is right associative the value will be 1..  in other words, which side is evaluated first.
		 */
		public function get a():Number {
			return this.numAssociativity;	
		}
		
	}
}