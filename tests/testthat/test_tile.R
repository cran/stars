mat = matrix(0L, 10, 10)

test1 = st_tile(nrow(mat), ncol(mat), 10, 10)
test_that("one block", {
	expect_equal(nrow(test1), 1)
	expect_setequal(test1, c(1, 1, 10, 10))
	# output matrix should be integer to best performance
	expect_type(test1, "integer")
})

test2 = st_tile(nrow(mat), ncol(mat), 5, 5)
test_that("equal blocks", {
	expect_equal(nrow(test2), 4)
})

test3 = st_tile(nrow(mat), ncol(mat), 9, 5)
test_that("different size blocks", {
	expect_equal(nrow(test3), 4)
})

test4 = st_tile(nrow(mat), ncol(mat), 1, 1)
test_that("many small blocks ", {
	expect_equal(nrow(test4), 100)
	expect_setequal(test4[, "nXOff"], rep(1:10, each = 10))
	expect_setequal(test4[, "nYOff"], rep(1:10, times = 10))
	expect_setequal(test4[, "nXSize"], rep(1, times = 100))
	expect_setequal(test4[, "nYSize"], rep(1, times = 100))
})

test5 = st_tile(nrow(mat), ncol(mat), 5, 5, overlap = 5)
test_that("blocks with overlap", {
	expect_equal(nrow(test5), 4)
	expect_setequal(test5[, "nXSize"], rep(c(10, 5), each = 2))
	expect_setequal(test5[, "nYSize"], rep(c(10, 5), times = 2))
})
