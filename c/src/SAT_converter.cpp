// SAT_converter.cpp
// Nicholas Mosier
// 3.9.2018
//
// converts SAT problems in the form
//     (x1 | x2 | ... | xn) & ... & (!x1 | x2 | ... | xi)
// to a bus compatible with Verilog

#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <stdio.h>

#include <iostream>
#include <string>
#include <vector>
#include <set>
#include <unordered_map>

#define STR_MAXLEN 1000
#define TAB_SIZE 100

using namespace std;

int getclause();
void printbus(vector< set<int> >&);

char name[STR_MAXLEN+1];
int name_i;

unordered_map<string,int> name_tab;
vector< set<int> > clause_inputs, clause_inputs_inv;
int N, M;

int main() {
	char c;
	
	// read input
	while ((c=getchar()) != EOF) {
		name_i = 0;
		while (isspace(c) || c == '&')
			{ c = getchar(); }
		if (c != '(') {
			fprintf(stderr, "unexpected character '%c' expected", c);
			return 1;
		}
		getclause();
	}
	
	N = name_tab.size();
	M = clause_inputs.size();
	cout << "N=" << N << endl;
	cout << "M=" << M << endl;
	
	for ()
	
	printbus(clause_inputs);
	printbus(clause_inputs_inv);
	
	return 0;
}

// on entry: opening paren '(' already read
// on exit: read thru closing paren ')'
int getclause() {
	char *name_new;
	int name_id;
	set<int> input_ids, input_inv_ids;
	
	char c = getchar();
	while (isspace(c))	// strip leading whitespace
				{ c = getchar(); }
	while (c != ')') {
		bool inverted;
		name_i = 0;
		inverted = (c == '!' || c == '~');
		if (inverted)
			{ c = getchar(); }
		
		while (name_i < STR_MAXLEN && !isspace(c) && c != '|' && c != '+' && c != ')') {
			name[name_i++] = c;
			c = getchar();
		}
		name[name_i] = '\0';
		
		if (name_tab.find(string(name)) == name_tab.end())
			{ name_id = name_tab[string(name)] = name_tab.size(); }
		else
			{ name_id = name_tab[string(name)]; }
		
		if (inverted)
			{ input_inv_ids.insert(name_id); }
		else
			{ input_ids.insert(name_id); }
		while (isspace(c) || c == '+' || c == '|')
				{ c = getchar(); }
	}
	clause_inputs.push_back(input_ids);
	clause_inputs_inv.push_back(input_inv_ids);
	return 0;
}

void printbus(vector< set<int> >& clauses) {
	cout << "{";
	for (int m = 0; m < M; ++m) {
		char bus[N+1];
		int i = 0;
		set<int>& inputs = clauses[m];
		
		for (int id : inputs) {
			for (; i < id; ++i)
				{ bus[i] = '0'; }
			bus[i++] = '1';
		}
		while (i < N)
			{ bus[i++] = '0'; }
		bus[i] = '\0';
		
		if (m > 0)
			{ cout << ", "; }
		printf("%d'b%s", N, bus);
	}
	cout << "}" << endl;
}