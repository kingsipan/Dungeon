grammar DungeonDSL;

@header{
    package antlr.main;
}

/*
 * Lexer rules
 */

TYPE_SPECIFIER
        : 'quest_config'
        ;

DOUBLE_LINE : '--';
ARROW       : '->';

TRUE : 'true';
FALSE: 'false';
ID  : [_a-zA-Z][a-zA-Z0-9_]*;
NUM : ([0-9]|[1-9][0-9]*);
NUM_DEC: [0-9]+'.'[0-9]+;
WS  : [ \t\r\n]+ -> skip;

LINE_COMMENT
        : '//' ~[\r\n]* -> channel(HIDDEN)
        ;

BLOCK_COMMENT
        : '/*' .*? '*/' -> channel(HIDDEN)
        ;


STRING_LITERAL  : '\'' ( STRING_ESCAPE_SEQ | ~[\\\r\n\f'] )* '\''
                | '"' ( STRING_ESCAPE_SEQ | ~[\\\r\n\f"] )* '"'
                ;

/*
 * fragments
 */
fragment STRING_ESCAPE_SEQ
    : '\\' .
    ;

/*
 * Parser rules
 */

// TODO:
// - expression grammar
// - proper stmt definition

program : definition* EOF
        //| stmt
        ;

definition
        : dot_def
        | object_def
        | entity_type_def
        | fn_def
        ;

fn_def
    : 'fn' ID '(' param_def_list? ')' ret_type_def? stmt_block
    ;

stmt
    : primary ';'
    | stmt_block
    | conditional_stmt
    | return_stmt
    ;

stmt_block
    : '{' stmt_list? '}'
    ;

stmt_list
    : stmt stmt_list
    | stmt
    ;

return_stmt
    : 'return' primary? ';'
    ;

conditional_stmt
    : 'if' primary stmt else_stmt?
    ;

else_stmt
    : 'else' stmt
    ;

ret_type_def
    : ARROW type_id=ID
    ;

param_def
    : typde_id=ID param_id=ID
    ;

param_def_list
        : param_def ',' param_def_list
        | param_def
        ;

entity_type_def
        : 'entity_type' ID '{' component_def_list? '}' ;

// used to specify, which components should be used in a game object
component_def_list
        : aggregate_value_def ',' component_def_list
        | aggregate_value_def
        ;

aggregate_value_def
        : type_id=ID
        | type_id=ID '{' property_def_list? '}' ;

object_def  : type_id=TYPE_SPECIFIER object_id=ID '{' property_def_list? '}' #grammar_type_obj_def
            | type_id=ID object_id=ID '{' property_def_list? '}' #other_type_obj_def
            ;

property_def_list
        : property_def ',' property_def_list
        | property_def
        ;

property_def
        : ID ':' primary;

func_call
        : ID '(' param_list? ')'
        ;

param_list
        : primary ',' param_list
        | primary
        ;

primary : ID
        | STRING_LITERAL
        | TRUE
        | FALSE
        | NUM
        | NUM_DEC
        | func_call
        | aggregate_value_def
        ;

/*
 * -------------------- dot related definitions --------------------
 * dot grammar: https://graphviz.org/doc/info/lang.html
 *
 * simplifications:
 * - don't support subgraphs
 * - don't support ports
 */

dot_def : graph_type=('graph'|'digraph') ID '{' dot_stmt_list? '}' ;

dot_stmt_list
        : dot_stmt ';'? dot_stmt_list?
        ;

dot_stmt
        : dot_node_stmt
        | dot_edge_stmt
        | dot_attr_stmt
        | dot_assign_stmt
        ;

dot_assign_stmt
        : ID '=' ID
        ;

dot_edge_stmt
        : ID dot_edge_RHS+ dot_attr_list?
        ;

dot_edge_RHS
        : dot_edge_op ID
        ;

// dot specifies the keywords as case insensitive,
// we require them to be lowercase for simplicity
dot_attr_stmt
        : ('graph' | 'node' | 'edge') dot_attr_list
        ;

dot_node_stmt
        : ID dot_attr_list?
        ;

dot_attr_list
        : '[' dot_a_list? ']' dot_a_list?
        ;

dot_a_list
        : ID '=' ID (';'|',')? dot_a_list?
        ;

dot_edge_op
        : ARROW
        | DOUBLE_LINE
        ;
