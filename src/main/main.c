
#include <stdio.h>
#include <stdlib.h>

#include <AST.h>
#include <builtins.h>
#include <error.h>
#include <hvm.h>
#include <parser.h>

#include <files.h>

int main(int argc, char *argv[]) {
    for (uint32_t i = 0; i < 1; i++) {
        printf("iteration: %i\n", i);

        if (argc < 2) {
            printf("please give the helios compiler a file to compile.\n");
            exit(-1);
        }
        char *file = readfiletostring(argv[1]);

        garbagecollector *gc = helios_init_garbagecollector();
        helios_set_garbagecollector(gc);

        AST *ast = parser_parseString(file);
        AST_print(ast);

        helios_object *code = helios_code_from_AST(ast);
        hvm_execute_codeobject(code);

        free(file);
        AST_free(ast);
        helios_delete_garbagecollector(gc);
    }
    return 0;
}
