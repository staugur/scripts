// 封装内嵌数据库 NutsDB

package db

import (
	"path/filepath"

	"github.com/xujiajun/nutsdb"
)

// Bucket 即 NutsDB 桶，表示一个文档项目名称
type Bucket = string

// DB 一个数据库连接结构
type DB struct {
	// subdir in rtfd.cfg base_dir
	DBDir string
	// instance of nutsdb
	obj *nutsdb.DB
}

// New 打开一个DB连接
func New(DBDir string) (db *DB, err error) {
	opt := nutsdb.DefaultOptions
	opt.Dir = DBDir
	connect, err := nutsdb.Open(opt)
	if err != nil {
		return
	}
	return &DB{DBDir, connect}, nil
}

// Close 关闭连接
func (db *DB) Close() error {
	err := db.obj.Close()
	if err != nil {
		return err
	}
	return nil
}

// Set 添加数据
func (db *DB) Set(name Bucket, key, value []byte) error {
	return db.ExpireSet(name, key, value, 0)
}

// ExpireSet 添加数据（使用过期时间）
func (db *DB) ExpireSet(name Bucket, key, value []byte, ttl uint32) error {
	if err := db.obj.Update(
		func(tx *nutsdb.Tx) error {
			if err := tx.Put(name, key, value, ttl); err != nil {
				return err
			}
			return nil
		}); err != nil {
		return err
	}
	return nil
}

// Get 获取数据
func (db *DB) Get(name Bucket, key []byte) (value []byte, err error) {
	if err = db.obj.View(
		func(tx *nutsdb.Tx) error {
			e, err := tx.Get(name, key)
			if err != nil {
				return err
			}
			value = e.Value
			return nil
		}); err != nil {
		return
	}
	return value, nil
}

// Has 判断 桶 中是否有Key（特指k/v类型）
func (db *DB) Has(name Bucket, key []byte) bool {
	_, err := db.Get(name, key)
	if err == nil {
		return true
	}
	return false
}

// Delete 删除Key（并不能删除其他数据类型）
func (db *DB) Delete(name Bucket, key []byte) error {
	if err := db.obj.Update(
		func(tx *nutsdb.Tx) error {
			if err := tx.Delete(name, key); err != nil {
				return err
			}
			return nil
		}); err != nil {
		return err
	}
	return nil
}

// RPush 从指定bucket里面的指定队列key的右边入队一个或者多个元素
func (db *DB) RPush(name Bucket, key []byte, items ...[]byte) error {
	if err := db.obj.Update(
		func(tx *nutsdb.Tx) error {
			return tx.RPush(name, key, items...)
		}); err != nil {
		return err
	}
	return nil
}

// LPop 从指定bucket里面的指定队列key的左边出队一个元素，删除并返回
func (db *DB) LPop(name Bucket, key []byte) (item []byte, err error) {
	if err = db.obj.Update(
		func(tx *nutsdb.Tx) error {
			data, err := tx.LPop(name, key)
			if err != nil {
				return err
			}
			item = data
			return nil
		}); err != nil {
		return
	}
	return item, nil
}

// RPop 从指定bucket里面的指定队列key的右边出队一个元素，删除并返回
func (db *DB) RPop(name Bucket, key []byte) (item []byte, err error) {
	if err = db.obj.Update(
		func(tx *nutsdb.Tx) error {
			data, err := tx.RPop(name, key)
			if err != nil {
				return err
			}
			item = data
			return nil
		}); err != nil {
		return
	}
	return item, nil
}

// LSize 返回指定bucket下指定key列表的size大小（即列表元素数量）
func (db *DB) LSize(name Bucket, key []byte) (length int, err error) {
	if err = db.obj.Update(
		func(tx *nutsdb.Tx) error {
			size, err := tx.LSize(name, key)
			if err != nil {
				return err
			}
			length = size
			return nil
		}); err != nil {
		return
	}
	return length, nil
}

// LRange 返回指定bucket里面的指定队列key列表里指定范围内的元素。
// start 和 end 偏移量都是基于0的下标，即list的第一个元素下标是0，依次递增；
// 偏移量也可以是负数，表示偏移量是从list尾部开始计数。
func (db *DB) LRange(name Bucket, key []byte, start, end int) (items [][]byte, err error) {
	err = db.obj.View(
		func(tx *nutsdb.Tx) error {
			data, err := tx.LRange(name, key, start, end)
			if err != nil {
				return err
			}
			items = data
			return nil
		})
	if err != nil {
		return
	}
	return items, nil
}

// SAdd 添加一个指定的member元素到指定bucket的里的指定集合key中。
func (db *DB) SAdd(name Bucket, key []byte, members ...[]byte) error {
	if err := db.obj.Update(
		func(tx *nutsdb.Tx) error {
			return tx.SAdd(name, key, members...)
		}); err != nil {
		return err
	}
	return nil
}

// SRem 在指定bucket里面移除指定的key集合中移除指定的一个或者多个元素。
func (db *DB) SRem(name Bucket, key []byte, members ...[]byte) error {
	if err := db.obj.Update(
		func(tx *nutsdb.Tx) error {
			if err := tx.SRem(name, key, members...); err != nil {
				return err
			}
			return nil
		}); err != nil {
		return err
	}
	return nil
}

// SHasKey 判断bucket是否有某个key（特指set数据类型），发生错误时即不存在
func (db *DB) SHasKey(name Bucket, key []byte) bool {
	hasKey := false
	if err := db.obj.View(
		func(tx *nutsdb.Tx) error {
			ok, err := tx.SHasKey(name, key)
			if err != nil {
				return err
			}
			hasKey = ok
			return nil
		}); err != nil {
		return false
	}
	return hasKey
}

// SIsMember 返回成员member是否是指定bucket的存指定key集合的成员。
func (db *DB) SIsMember(name Bucket, key, member []byte) bool {
	is := false
	if err := db.obj.View(
		func(tx *nutsdb.Tx) error {
			ok, err := tx.SIsMember(name, key, member)
			if err != nil {
				return err
			}
			is = ok
			return nil
		}); err != nil {
		return false
	}
	return is
}

// SMembers 返回指定bucket的指定key集合所有的元素。
func (db *DB) SMembers(name Bucket, key []byte) (members [][]byte, err error) {
	if err = db.obj.View(
		func(tx *nutsdb.Tx) error {
			items, err := tx.SMembers(name, key)
			if err != nil {
				return err
			}
			members = items
			return nil
		}); err != nil {
		return
	}
	return members, nil
}

// SCard 返回指定bucket的指定的集合key的基数 (集合元素的数量)。
func (db *DB) SCard(name Bucket, key []byte) (length int, err error) {
	if err = db.obj.View(
		func(tx *nutsdb.Tx) error {
			num, err := tx.SCard(name, key)
			if err != nil {
				return err
			}
			length = num
			return nil
		}); err != nil {
		return
	}
	return length, nil
}

// Pipeline 开启事务并执行命令
func (db *DB) Pipeline() (t *TranCommand, err error) {
	// 开启事务
	tx, err := db.obj.Begin(true)
	if err != nil {
		return
	}
	return &TranCommand{tx}, nil
}

// TranCommand 表示事务管道
type TranCommand struct {
	tx *nutsdb.Tx
}

// AutoRollback 管道执行发生错误时自动回滚事务
func (t *TranCommand) AutoRollback(err error) error {
	if err != nil {
		// 回滚事务
		t.tx.Rollback()
		return err
	}
	return nil
}

// Set 管道中的 Set
func (t *TranCommand) Set(name Bucket, key, value []byte) error {
	return t.ExpireSet(name, key, value, 0)
}

// ExpireSet 管道中的 ExpireSet
func (t *TranCommand) ExpireSet(name Bucket, key, value []byte, ttl uint32) error {
	return t.AutoRollback(t.tx.Put(name, key, value, ttl))
}

// Delete 管道中的 Delete
func (t *TranCommand) Delete(name Bucket, key []byte) error {
	return t.AutoRollback(t.tx.Delete(name, key))
}

// RPush 管道中的 RPush
func (t *TranCommand) RPush(name Bucket, key []byte, items ...[]byte) error {
	return t.AutoRollback(t.tx.RPush(name, key, items...))
}

// SAdd 管道中的 SAdd
func (t *TranCommand) SAdd(name Bucket, key []byte, members ...[]byte) error {
	return t.AutoRollback(t.tx.SAdd(name, key, members...))
}

// SRem 管道中的 SRem
func (t *TranCommand) SRem(name Bucket, key []byte, members ...[]byte) error {
	return t.AutoRollback(t.tx.SRem(name, key, members...))
}

// Execute 执行提交事务
func (t *TranCommand) Execute() error {
	if err := t.tx.Commit(); err != nil {
		t.tx.Rollback()
		return err
	}
	return nil
}
