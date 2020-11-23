/*
 * Copyright 1999-2018 Alibaba Group Holding Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.alibaba.nacos.config.server.service.repository.extrnal;

import com.alibaba.nacos.config.server.model.Page;
import com.alibaba.nacos.config.server.service.repository.PaginationHelper;
import com.alibaba.nacos.config.server.service.sql.EmbeddedStorageContextUtils;
import com.alibaba.nacos.config.server.utils.PropertyUtil;
import com.alibaba.nacos.core.utils.ApplicationUtils;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.util.Arrays;
import java.util.List;

/**
 * External Storage Pagination utils.
 *
 * @author <a href="mailto:liaochuntao@live.com">liaochuntao</a>
 */

class ExternalStoragePaginationHelperImpl<E> implements PaginationHelper {

    private final JdbcTemplate jdbcTemplate;
    private String dbType = null;
    public ExternalStoragePaginationHelperImpl(JdbcTemplate jdbcTemplate) {

        this.jdbcTemplate = jdbcTemplate;
        this.dbType = ApplicationUtils.getProperty("spring.datasource.platform");
    }

    /**
     * Take paging.
     *
     * @param sqlCountRows query total SQL
     * @param sqlFetchRows query data sql
     * @param args         query parameters
     * @param pageNo       page number
     * @param pageSize     page size
     * @param rowMapper    {@link RowMapper}
     * @return Paginated data {@code <E>}
     */
    public Page<E> fetchPage(final String sqlCountRows, final String sqlFetchRows, final Object[] args,
            final int pageNo, final int pageSize, final RowMapper rowMapper) {
        return fetchPage(sqlCountRows, sqlFetchRows, args, pageNo, pageSize, null, rowMapper);
    }

    public Page<E> fetchPage(final String sqlCountRows, final String sqlFetchRows, final Object[] args,
            final int pageNo, final int pageSize, final Long lastMaxId, final RowMapper rowMapper) {
        if (pageNo <= 0 || pageSize <= 0) {
            throw new IllegalArgumentException("pageNo and pageSize must be greater than zero");
        }

        // Query the total number of current records.
        Integer rowCountInt = jdbcTemplate.queryForObject(sqlCountRows, args, Integer.class);
        if (rowCountInt == null) {
            throw new IllegalArgumentException("fetchPageLimit error");
        }

        // Compute pages count
        int pageCount = rowCountInt / pageSize;
        if (rowCountInt > pageSize * pageCount) {
            pageCount++;
        }

        // Create Page object
        final Page<E> page = new Page<E>();
        page.setPageNumber(pageNo);
        page.setPagesAvailable(pageCount);
        page.setTotalCount(rowCountInt);

        if (pageNo > pageCount) {
            return page;
        }

        final int startRow = (pageNo - 1) * pageSize;
        String selectSql = "";
        if (isDerby()) {
            selectSql = sqlFetchRows + " OFFSET " + startRow + " ROWS FETCH NEXT " + pageSize + " ROWS ONLY";
        } else if ("gbasedbt".equalsIgnoreCase(this.dbType)){
            if (lastMaxId != null) {
                selectSql = sqlFetchRows + " and id > " + lastMaxId + " order by id asc" + " skip " + 0 + " first " + pageSize;
            } else {
                selectSql = sqlFetchRows + " skip " + startRow + " first " + pageSize;
            }
        } else {
            if (lastMaxId != null) {
                selectSql = sqlFetchRows + " and id > " + lastMaxId + " order by id asc" + " limit " + 0 + "," + pageSize;
            } else {
                selectSql = sqlFetchRows + " limit " + startRow + "," + pageSize;
            }
        }

        List<E> result = jdbcTemplate.query(selectSql, args, rowMapper);
        for (E item : result) {
            page.getPageItems().add(item);
        }
        return page;
    }

    public Page<E> fetchPageLimit(final String sqlCountRows, final String sqlFetchRows, final Object[] args,
            final int pageNo, final int pageSize, final RowMapper rowMapper) {
        if (pageNo <= 0 || pageSize <= 0) {
            throw new IllegalArgumentException("pageNo and pageSize must be greater than zero");
        }
        // Query the total number of current records
        Integer rowCountInt = jdbcTemplate.queryForObject(sqlCountRows, Integer.class);
        if (rowCountInt == null) {
            throw new IllegalArgumentException("fetchPageLimit error");
        }

        // Compute pages count
        int pageCount = rowCountInt / pageSize;
        if (rowCountInt > pageSize * pageCount) {
            pageCount++;
        }

        // Create Page object
        final Page<E> page = new Page<E>();
        page.setPageNumber(pageNo);
        page.setPagesAvailable(pageCount);
        page.setTotalCount(rowCountInt);

        if (pageNo > pageCount) {
            return page;
        }

        String selectSql = sqlFetchRows;
        Object[] myargs =args;
        if (isDerby()) {
            selectSql = selectSql.replaceAll("(?i)LIMIT \\?,\\?", "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        } else if ("gbasedbt".equalsIgnoreCase(this.dbType)){
//            selectSql = selectSql.replaceAll("(?i)LIMIT \\?,\\?", "skip ? first ?");
            selectSql = generalGBasedbtSql(selectSql,args);
            myargs = Arrays.copyOf(args,args.length-2);
        }

        List<E> result = jdbcTemplate.query(selectSql, myargs, rowMapper);
        for (E item : result) {
            page.getPageItems().add(item);
        }
        return page;
    }

    public Page<E> fetchPageLimit(final String sqlCountRows, final Object[] args1, final String sqlFetchRows,
            final Object[] args2, final int pageNo, final int pageSize, final RowMapper rowMapper) {
        if (pageNo <= 0 || pageSize <= 0) {
            throw new IllegalArgumentException("pageNo and pageSize must be greater than zero");
        }
        // Query the total number of current records
        Integer rowCountInt = jdbcTemplate.queryForObject(sqlCountRows, args1, Integer.class);
        if (rowCountInt == null) {
            throw new IllegalArgumentException("fetchPageLimit error");
        }

        // Compute pages count
        int pageCount = rowCountInt / pageSize;
        if (rowCountInt > pageSize * pageCount) {
            pageCount++;
        }

        // Create Page object
        final Page<E> page = new Page<E>();
        page.setPageNumber(pageNo);
        page.setPagesAvailable(pageCount);
        page.setTotalCount(rowCountInt);

        if (pageNo > pageCount) {
            return page;
        }

        String selectSql = sqlFetchRows;
        Object[] myargs = args2;
        if (isDerby()) {
            selectSql = selectSql.replaceAll("(?i)LIMIT \\?,\\?", "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        } else if ("gbasedbt".equalsIgnoreCase(this.dbType)){
//            selectSql = selectSql.replaceAll("(?i)LIMIT \\?,\\?", "skip ? first ?");
            selectSql = generalGBasedbtSql(selectSql,args2);
            myargs = Arrays.copyOf(args2,args2.length-2);
        }

        List<E> result = jdbcTemplate.query(selectSql, myargs, rowMapper);
        for (E item : result) {
            page.getPageItems().add(item);
        }
        return page;
    }

    public Page<E> fetchPageLimit(final String sqlFetchRows, final Object[] args, final int pageNo, final int pageSize,
            final RowMapper rowMapper) {
        if (pageNo <= 0 || pageSize <= 0) {
            throw new IllegalArgumentException("pageNo and pageSize must be greater than zero");
        }
        // Create Page object
        final Page<E> page = new Page<E>();
        Object[] myargs = args;
        String selectSql = sqlFetchRows;
        if (isDerby()) {
            selectSql = selectSql.replaceAll("(?i)LIMIT \\?,\\?", "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        } else if ("gbasedbt".equalsIgnoreCase(this.dbType)){
//              selectSql = selectSql.replaceAll("(?i)LIMIT \\?,\\?", "skip ? first ?");
                selectSql = generalGBasedbtSql(selectSql,args);
                myargs = Arrays.copyOf(args,args.length-2);
        }
        List<E> result = jdbcTemplate.query(selectSql, myargs, rowMapper);

        for (E item : result) {
            page.getPageItems().add(item);
        }
        return page;
    }

    public void updateLimit(final String sql, final Object[] args) {
        String sqlUpdate = sql;

        if (isDerby()) {
            sqlUpdate = sqlUpdate.replaceAll("limit \\?", "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY");
        } else if ("gbasedbt".equalsIgnoreCase(this.dbType)){
            sqlUpdate = sqlUpdate.replaceAll("limit \\?", "first ?");
        }

        try {
            jdbcTemplate.update(sqlUpdate, args);
        } finally {
            EmbeddedStorageContextUtils.cleanAllContext();
        }
    }

    private boolean isDerby() {
        return (ApplicationUtils.getStandaloneMode() && !PropertyUtil.isUseExternalDB()) || PropertyUtil
                .isEmbeddedStorage();
    }

    private String generalGBasedbtSql(String oriSql,Object[] args){
        int paramLength = args.length;
        Object pageStart = args[paramLength-2];
        Object pageEnd = args[paramLength-1];
        return oriSql.replaceAll("(?i)LIMIT \\?,\\?", "skip "+pageStart+" first "+pageEnd);
    }
}
