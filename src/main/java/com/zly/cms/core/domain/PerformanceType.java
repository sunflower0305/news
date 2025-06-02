package com.zly.cms.core.domain;

import com.zly.cms.core.domain.base.PerformanceTypeBase;
import com.zly.commons.db.order.OrderEntity;

import java.io.Serializable;

/**
 * @author PONY
 */
public class PerformanceType extends PerformanceTypeBase implements Serializable, OrderEntity {
    private static final long serialVersionUID = 1L;

    public static final String NOT_FOUND = "PerformanceType not found. ID: ";
}