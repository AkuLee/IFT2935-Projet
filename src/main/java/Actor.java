/*
 * Hibernate, Relational Persistence for Idiomatic Java
 *
 * Copyright (c) 2010, Red Hat Inc. or third-party contributors as
 * indicated by the @author tags or express copyright attribution
 * statements applied by the authors.  All third-party contributions are
 * distributed under license by Red Hat Inc.
 *
 * This copyrighted material is made available to anyone wishing to use, modify,
 * copy, or redistribute it subject to the terms and conditions of the GNU
 * Lesser General Public License, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this distribution; if not, write to:
 * Free Software Foundation, Inc.
 * 51 Franklin Street, Fifth Floor
 * Boston, MA  02110-1301  USA
 */

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

import org.hibernate.annotations.GenericGenerator;

@Entity
@Table( name = "ACTOR" )
public class Actor {
    private Long actor_id;
    private String first_name;
    private String last_name;
    private Date last_update;

    public Actor() {
        // this form used by Hibernate
    }

    public Actor(String first, String last, Date date) {
        // for application use, to create new events
        this.first_name = first;
        this.last_name = last;
        this.last_update = date;
    }

    @Id
    @GeneratedValue(generator="increment")
    @GenericGenerator(name="increment", strategy = "increment")
    @Column(name = "ACTOR_ID")
    public Long getActor_id() {
        return actor_id;
    }

    private void setActor_id(Long actor_id) {
        this.actor_id = actor_id;
    }

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "LAST_UPDATE")
    public Date getLast_update() {
        return last_update;
    }

    public void setLast_update(Date date) {
        this.last_update = date;
    }

    @Column(name = "FIRST_NAME")
    public String getFirst_name() {
        return first_name;
    }

    public void setFirst_name(String first_name) {
        this.first_name = first_name;
    }

    @Column(name = "LAST_NAME")
    public String getLast_name() {
        return last_name;
    }

    public void setLast_name (String last) {
        this.last_name = last;
    }
}