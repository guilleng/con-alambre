CC := gcc
CFLAGS := -std=c89 -g -Wall -Wextra -Wpedantic

TESTFLAGS := -Wno-unused-parameter
TESTLDFLAGS := -lm -lrt

INC_DIR := ./include
OBJ_DIR := ./obj
SRC_DIR := ./src
TEST_DIR := ./tests
TEST_BIN := ./tests/bin

SRCS := $(wildcard $(SRC_DIR)/*.c)
OBJS := $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(SRCS))

TEST_OBJS := $(patsubst $(SRC_DIR)/%.c, $(TEST_BIN)/%.o, $(SRCS))
TEST_SRCS := $(wildcard $(TEST_DIR)/test_*.c)
TEST_EXEC := $(patsubst $(TEST_DIR)/%.c, $(TEST_BIN)/%, $(TEST_SRCS))

all: $(OBJS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(INC_DIR)/%.h | $(OBJ_DIR)
	@$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

# The recipe filters out the object file corresponding to the current target,
# otherwise we will attempt at linking it it twice.
$(TEST_BIN)/test_%_priv: $(TEST_DIR)/test_%_priv.c $(SRC_DIR)/%.c $(TEST_OBJS) | $(TEST_BIN)
	@$(CC) $(CFLAGS) -I$(INC_DIR) $< $(filter-out $(TEST_BIN)/$*.o, $(TEST_OBJS)) -o $@ 

$(TEST_BIN)/test_%_publ: $(TEST_DIR)/test_%_publ.c $(SRC_DIR)/%.c $(INC_DIR)/%.h $(TEST_OBJS) | $(TEST_BIN)
	@$(CC) $(CFLAGS) -I$(INC_DIR) $< $(TEST_OBJS) -o $@ 

$(TEST_BIN)/%.o: $(SRC_DIR)/%.c | $(TEST_BIN)
	@$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

 $(OBJ_DIR) $(TEST_BIN):
	@mkdir -p $@

.PHONY: all tests clean

.PRECIOUS: $(TEST_OBJS)

# Tests all units, output shown only in case of failure. (No news is good news.)
tests: CFLAGS += $(TESTLDFLAGS)
tests: CFLAGS += $(TESTFLAGS)
tests: $(TEST_EXEC)
	@for test in $^; do \
		./$$test > /dev/null 2>&1; \
		exit_code=$$?; \
		if [ ! $$exit_code -eq 0 ]; then \
			echo "\nFail: $$test\nExit code: $$exit_code\n"; \
			exit 1; \
		fi; \
	done; \

# Test a specific module or interface showing detailed output.
test_%: CFLAGS += $(TESTLDFLAGS) 
test_%: CFLAGS += $(TESTFLAGS) 
test_%: $(TEST_BIN)/test_%
	./$(TEST_BIN)/$@ 

clean:
	@rm -rf $(OBJ_DIR) $(TEST_BIN)
